classdef (Abstract) SchemaCollection < handle
% SCHEMACOLLECTION (abstract)
%
% Description:
%   A collection of specifications for a specific AOData entity type.
%
% Superclasses:
%   handle
%
% Constructor:
%   obj = aod.schema.SchemaCollection(className)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (Abstract, Hidden, SetAccess = protected)
        % The specification type
        schemaType          string
        ALLOWABLE_PRIMITIVE_TYPES
    end

    properties (SetAccess = protected)
        Parent
        className
        Entries
    end

    properties (Hidden, SetAccess = private)
        lastModified        datetime = datetime.empty()
    end

    properties (Dependent)
        Count       (1,1)   double      {mustBeInteger}
        Contents            string
    end

    methods
        function obj = SchemaCollection(className, parent)
            if nargin > 0 && ~aod.util.isempty(className)
                obj.className = convertCharsToStrings(className);
            end
            if nargin > 1
                obj.setParent(parent);
            end
            obj.lastModified = datetime('now');
        end
    end

    % Dependent methods
    methods
        function value = get.Count(obj)
            value = numel(obj.Entries);
        end

        function value = get.Contents(obj)
            value = obj.list()';
        end
    end

    methods
        function [tf, ME] = validate(obj, specName, value)
            % Exception should contain:
            %   - Class and entry name
            %   - Number of failures
            %   - Names of failed validators
            % The addCause function looks valuable in this regard

            p = obj.get(specName, aod.infra.ErrorTypes.ERROR);
            [tf, ME] = p.validate(value);
        end

        function [tf, ME, failedEntries] = checkIntegrity(obj, specName)
            failedEntries = [];
            if nargin < 1 || isempty(specName)
                if obj.Count == 0
                    tf = true; ME = [];
                    return
                end
                didPass = true(obj.Count, 1);
                for i = 1:obj.Count
                    [iPassed, iME] = obj.Entries(i).checkIntegrity();
                    didPass(i) = iPassed;
                    ME = cat(1, ME, iME);
                end
                failedEntries = obj.Contents(didPass);
            else
                p = obj.get(specName, aod.infra.ErrorTypes.ERROR);
                [tf, ME] = p.checkIntegrity();
            end
        end

        function set(obj, entryName, primitiveType, varargin)
            % SET Set the type and options of an entry's primitive
            % -------------------------------------------------------------


            entry = obj.get(entryName);
            if isempty(entry)
                error('set:EntryNotFound',...
                    '%s does not have the %s "%s"', ...
                    obj.className, obj.schemaType, entryName);
            end

            primitiveType = aod.schema.primitives.PrimitiveTypes.init(primitiveType);
            % TODO: Ensure type is valid for collection
            if primitiveType ~= entry.primitiveType
                entry.setType(primitiveType);
            end

            entry.assign(varargin{:});
        end

        function [tf, idx] = has(obj, entryName)
            % Determine whether Manager has a entry
            %
            % Syntax:
            %   [tf, idx] = has(obj, entryName)
            % -------------------------------------------------------------
            arguments
                obj
                entryName        string
            end

            if obj.Count == 0
                tf = false; idx = [];
                return
            end
            allNames = obj.list();
            idx = find(allNames == entryName);
            tf = ~isempty(idx);
        end

        function entry = get(obj, entryName, errorType)
            % Get a dataset by name
            %
            % Syntax:
            %   entry = get(obj, entryName)
            %   entry = get(obj, entryName, errorType)
            %
            % Inputs:
            %   entryName           char
            %       The name of the dataset or attribute (case-sensitive)
            % Optional inputs:
            %   errorType           char or aod.infra.ErrorTypes
            %       How to handle missing property: 'none', 'error', or
            %       'warning'. Default is 'none' and the output will be []
            %
            % Outputs:
            %   entry               aod.specification.Entry
            % -------------------------------------------------------------
            arguments
                obj
                entryName       char
                errorType       = aod.infra.ErrorTypes.NONE
            end

            [tf, idx] = obj.has(entryName);

            if tf
                entry = obj.Entries(idx);
            else
                switch errorType
                    case aod.infra.ErrorTypes.NONE
                        entry = [];
                    case aod.infra.ErrorTypes.ERROR
                        error('get:EntryNotFound',...
                            'Entry %s not found in %sManager',...
                            entryName, obj.schemaType);
                    case aod.infra.ErrorTypes.WARNING
                        warning('get:EntryNotFound',...
                            'Entry %s not found in %sManager',...
                            entryName, obj.schemaType);
                    case aod.infra.ErrorTypes.MISSING
                        error("get:InvalidInput",...
                            "Missing error type is not supported");
                end
            end
        end

        function add(obj, entry)
            % Add a new dataset/attribute
            %
            % Syntax:
            %   add(obj, entry)
            %
            % Inputs:
            %   entry          aod.specification.Entry
            %
            % See also:
            %   aod.specification.Entry
            % -------------------------------------------------------------
            arguments
                obj
                entry         aod.schema.Entry
            end

            if obj.Count > 0 && ismember(lower(entry.Name), lower(obj.list()))
                error('add:EntryExists',...
                    'A %s named %s is already present', entry.schemaType, entry.Name);
            end
            obj.Entries = [obj.Entries; entry];
        end

        function remove(obj, entryName)
            % Remove an entry
            %
            % Syntax:
            %   remove(obj, entryName)
            % -------------------------------------------------------------
            [tf, idx] = obj.has(entryName);
            if ~tf
                return
            end
            obj.Entries(idx) = [];
            % obj.listeners(idx) = []
        end

        function names = list(obj)
            % List all dataset names
            %
            % Syntax:
            %   names = list(obj)
            % -------------------------------------------------------------
            if obj.Count == 0
                names = [];
                return
            end

            names = arrayfun(@(x) x.Name, obj.Entries);
        end

        function out = text(obj)
            % Convert contents to text for display
            %
            % Syntax:
            %   out = text(obj)
            % -------------------------------------------------------------
            if isempty(obj)
                out = sprintf("Empty %sCollection", obj.schemaType);
                return
            end

            out = "";
            for i = 1:obj.Count
                out = out + obj.Entries(i).text();
            end
        end
    end

    % Non-scalar property access
    methods
        function out = getClassName(obj)
            if ~isscalar(obj)
                out = arrayfun(@(x) x.className, obj);
                return
            end
            out = obj.className;
        end
    end

    methods (Access = private)
        function setParent(obj, entity)
            if nargin < 2 || isempty(entity)
                obj.Parent = [];
                return
            end

            assert(isa(entity, 'aod.schema.Entity'),...
                'Parent must be an AOData entity');

            obj.Parent = entity;
        end
    end


    % MATLAB builtin methods
    methods
        function tf = isempty(obj)
            tf = (obj.Count == 0);
        end

        function tf = isequal(obj, other)
            if ~isa(other, class(obj))
                tf = false;
                return
            end

            tf = true;  % True unless fails tests below
            if obj.className ~= other.className
                tf = false;
            elseif obj.Count ~= other.Count
                tf = false;
            elseif ~isequal(sort(obj.list()), sort(other.list()))
                tf = false;
            else
                thisList = obj.list();
                for i = 1:obj.Count
                    if ~isequal(obj.get(thisList(i)), other.get(thisList(i)))
                        tf = false;
                        return
                    end
                end
            end
        end

        function S = struct(obj)
            % Convert specified entries to a structure
            %
            % Syntax:
            %   S = struct(obj)
            % -------------------------------------------------------------
            S = struct();
            if isempty(obj)
                return
            end

            for i = 1:obj.Count
                iStruct = obj.Entries(i).struct();
                % Place into a struct named for the dataset
                S.(obj.Entries(i).Name) = iStruct;
            end
        end
    end
end