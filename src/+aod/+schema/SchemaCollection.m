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
%
% TODO: This could subclass IndexedCollection

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (Abstract, Hidden, SetAccess = protected)
        % The specification type
        schemaType          string
        ALLOWABLE_PRIMITIVE_TYPES
    end

    properties (SetAccess = protected)
        Parent              % aod.schema.EntitySchema
        className
        Records
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
            value = numel(obj.Records);
        end

        function value = get.Contents(obj)
            value = obj.list()';
        end
    end

    methods
        function [tf, ME] = validate(obj, specName, value)
            % Exception should contain:
            %   - Class and record name
            %   - Number of failures
            %   - Names of failed validators
            % The addCause function looks valuable in this regard

            p = obj.get(specName, aod.infra.ErrorTypes.ERROR);
            [tf, ME] = p.validate(value);
        end

        function [tf, ME, failedRecords] = checkIntegrity(obj, specName)
            failedRecords = [];
            if nargin < 1 || isempty(specName)
                if obj.Count == 0
                    tf = true; ME = [];
                    return
                end
                didPass = true(obj.Count, 1);
                for i = 1:obj.Count
                    [iPassed, iME] = obj.Records(i).checkIntegrity();
                    didPass(i) = iPassed;
                    ME = cat(1, ME, iME);
                end
                failedRecords = obj.Contents(didPass);
            else
                p = obj.get(specName, aod.infra.ErrorTypes.ERROR);
                [tf, ME] = p.checkIntegrity();
            end
        end

        function set(obj, recordName, primitiveType, varargin)
            % SET Set the type and options of an record's primitive
            % -------------------------------------------------------------


            record = obj.get(recordName);
            if isempty(record)
                error('set:EntryNotFound',...
                    '%s does not have the %s "%s"', ...
                    obj.className, obj.schemaType, recordName);
            end

            primitiveType = aod.schema.primitives.PrimitiveTypes.get(primitiveType);
            % TODO: Ensure type is valid for collection
            if primitiveType ~= record.primitiveType
                record.setType(primitiveType);
            end

            record.assign(varargin{:});
        end

        function [tf, idx] = has(obj, recordName)
            % Determine whether Manager has a record
            %
            % Syntax:
            %   [tf, idx] = has(obj, recordName)
            % -------------------------------------------------------------
            arguments
                obj
                recordName        string
            end

            if obj.Count == 0
                tf = false; idx = [];
                return
            end
            allNames = obj.list();
            idx = find(allNames == recordName);
            tf = ~isempty(idx);
        end

        function record = get(obj, recordName, errorType)
            % Get a dataset by name
            %
            % Syntax:
            %   record = get(obj, recordName)
            %   record = get(obj, recordName, errorType)
            %
            % Inputs:
            %   recordName           char
            %       The name of the dataset or attribute (case-sensitive)
            % Optional inputs:
            %   errorType           char or aod.infra.ErrorTypes
            %       How to handle missing property: 'none', 'error', or
            %       'warning'. Default is 'none' and the output will be []
            %
            % Outputs:
            %   record               aod.specification.Entry
            % -------------------------------------------------------------
            arguments
                obj
                recordName       char
                errorType       = aod.infra.ErrorTypes.NONE
            end

            [tf, idx] = obj.has(recordName);

            if tf
                record = obj.Records(idx);
            else
                switch errorType
                    case aod.infra.ErrorTypes.NONE
                        record = [];
                    case aod.infra.ErrorTypes.ERROR
                        error('get:EntryNotFound',...
                            'Entry %s not found in %sCollection',...
                            recordName, obj.schemaType);
                    case aod.infra.ErrorTypes.WARNING
                        warning('get:EntryNotFound',...
                            'Entry %s not found in %sCollection',...
                            recordName, obj.schemaType);
                    case aod.infra.ErrorTypes.MISSING
                        error("get:InvalidInput",...
                            "Missing error type is not supported");
                end
            end
        end

        function add(obj, record)
            % Add a new dataset/attribute
            %
            % Syntax:
            %   add(obj, record)
            %
            % Inputs:
            %   record          aod.schema.Record
            %
            % See also:
            %   aod.schema.Record
            % -------------------------------------------------------------
            arguments
                obj
                record         aod.schema.Record
            end

            if obj.Count > 0 && ismember(lower(record.Name), lower(obj.list()))
                error('add:RecordExists',...
                    'A %s named %s is already present', record.schemaType, record.Name);
            end
            obj.Records = [obj.Records; record];
        end

        function remove(obj, recordName)
            % Remove an record
            %
            % Syntax:
            %   remove(obj, recordName)
            % -------------------------------------------------------------
            [tf, idx] = obj.has(recordName);
            if ~tf
                return
            end
            obj.Records(idx) = [];
            % obj.listeners(idx) = []
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
                out = out + obj.Records(i).text();
            end
        end
    end

    % Non-scalar property access
    methods
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

            names = arrayfun(@(x) x.Name, obj.Records);
        end

        function primitiveTypes = getPrimitiveTypes(obj)
            if obj.Count == 0
                primitiveTypes = [];
            else
                primitiveTypes = arrayfun(@(x) x.primitiveType, obj.Records);
            end
        end

        function out = getClassName(obj)
            % TODO: Needed?
            if ~isscalar(obj)
                out = arrayfun(@(x) x.className, obj);
                return
            end
            out = obj.className;
        end
    end

    methods (Access = {?aod.schema.EntitySchema})
        function setParent(obj, parent)
            if nargin < 2 || isempty(parent)
                obj.Parent = [];
                return
            end

            mustBeSubclass(parent, "aod.common.mixins.Entity");

            obj.Parent = parent;
        end
    end


    % MATLAB builtin methods
    methods
        % TODO: Keep isempty()?
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
            % Convert specified records to a structure
            %
            % Syntax:
            %   S = struct(obj)
            % -------------------------------------------------------------
            S = struct();
            if isempty(obj)
                return
            end

            for i = 1:obj.Count
                iStruct = obj.Records(i).struct();
                % Place into a struct named for the dataset
                S.(obj.Records(i).Name) = iStruct;
            end
        end
    end
end