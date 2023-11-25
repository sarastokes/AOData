classdef (Abstract) RecordCollection < aod.schema.Collection
% SCHEMACOLLECTION (abstract)
%
% Description:
%   A collection of specifications for a specific AOData entity type.
%
% Superclasses:
%   handle
%
% Constructor:
%   obj = aod.schema.collections.RecordCollection(className)
%
% TODO: This could subclass IndexedCollection (?)

% By Sara Patterson, 2023 (AOData)
% ----------------------------------------------------------------------

    properties (Abstract, Hidden, SetAccess = protected)
        % The specification type
        recordType                      aod.schema.RecordTypes
        ALLOWABLE_PRIMITIVE_TYPES       aod.schema.PrimitiveTypes
    end

    properties (SetAccess = protected)
        Parent              % aod.schema.Schema
        className           string
        Records             % aod.schema.Record
    end

    properties (Hidden, SetAccess = protected)
        SCHEMA_OBJECT_TYPE              = aod.schema.SchemaObjectTypes.RECORD_COLLECTION
    end

    properties (Hidden, SetAccess = private)
        lastModified        datetime = datetime.empty()
    end

    properties (Dependent)
        Count       (1,1)   double      {mustBeInteger, mustBeNonnegative}
        Contents            string
    end

    methods
        function obj = RecordCollection(parent)
            if nargin > 0 && ~aod.util.isempty(parent)
                if istext(parent)
                    className = parent;
                else
                    obj.setParent(parent);
                    className = class(parent);
                end
                obj.className = convertCharsToStrings(className);
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
        function [tf, ME, excObj] = validate(obj, recordName, value, errorType)
            arguments
                obj
                recordName                  string
                value
                errorType                   = aod.infra.ErrorTypes.ERROR
            end

            p = obj.get(recordName, aod.infra.ErrorTypes.ERROR);
            [tf, ME, excObj] = p.validate(value, errorType);
        end

        function [tf, ME, failedRecords] = checkIntegrity(obj, recordName)
            failedRecords = [];
            if nargin < 2 || isempty(recordName)
                ME = [];
                if obj.Count == 0
                    tf = true;
                    return
                end
                didPass = true(obj.Count, 1);
                for i = 1:obj.Count
                    [iPassed, iME] = obj.Records(i).checkIntegrity();
                    didPass(i) = iPassed;
                    ME = cat(1, ME, iME);
                end
                failedRecords = obj.Contents(~didPass);
                tf = all(didPass);
            else
                p = obj.get(recordName, aod.infra.ErrorTypes.ERROR);
                [tf, ME] = p.checkIntegrity();
                if ~tf
                    failedRecords = recordName;
                end
            end
        end

        function [recordNames, idx] = getUndefined(obj)
            % GETUNDEFINED  Returns record names with UNKNOWN primitives
            %
            % Syntax:
            %   [recordNames, idx] = getUndefined(obj)
            % ----------------------------------------------------------

            if obj.Count == 0
                recordNames = string.empty();
                return
            end

            idx = arrayfun(@(x) x.isUndefined(), obj.Records);
            recordNames = obj.Contents(idx);
        end

        function set(obj, recordName, primitiveType, varargin)
            % SET Set the type and options of an record's primitive
            % ----------------------------------------------------------

            record = obj.get(recordName);
            if isempty(record)
                error('set:EntryNotFound',...
                    '%s does not have the %s "%s"', ...
                    obj.className, string(obj.recordType), recordName);
            end

            primitiveType = aod.schema.PrimitiveTypes.get(primitiveType);
            % Reset primitive if type has changed
            if primitiveType ~= record.primitiveType
                if ~ismember(primitiveType, obj.ALLOWABLE_PRIMITIVE_TYPES)
                    error('set:InvalidPrimitiveType',...
                        'PrimitiveType %s is not allowed for %s collections',...
                            string(primitiveType), string(obj.recordType));
                end
                %! The existing specifications will be overwritten
                record.setPrimitive(primitiveType);
            end

            record.assign(varargin{:});
        end

        function [tf, idx] = has(obj, recordName)
            % Determine whether Manager has a record
            %
            % Syntax:
            %   [tf, idx] = has(obj, recordName)
            % ----------------------------------------------------------
            arguments
                obj                 aod.schema.collections.RecordCollection
                recordName          string
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
            % ----------------------------------------------------------
            arguments
                obj
                recordName       string
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
                            recordName, string(obj.recordType));
                    case aod.infra.ErrorTypes.WARNING
                        warning('get:EntryNotFound',...
                            'Entry %s not found in %sCollection',...
                            recordName, string(obj.recordType));
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
            % ----------------------------------------------------------
            arguments
                obj             aod.schema.collections.RecordCollection
                record          aod.schema.Record
            end

            if obj.Count > 0 && ismember(lower(record.Name), lower(obj.list()))
                error('add:RecordExists',...
                    'A %s named %s is already present',...
                        string(obj.recordType), record.Name);
            end
            obj.Records = [obj.Records; record];
        end

        function remove(obj, recordName)
            % Remove an record
            %
            % Syntax:
            %   remove(obj, recordName)
            % ----------------------------------------------------------
            arguments
                obj             aod.schema.collections.RecordCollection
                recordName      string
            end

            [tf, idx] = obj.has(recordName);
            if ~tf
                return
            end

            obj.Records(idx) = [];
        end

        function out = text(obj)
            % Convert contents to text for display
            %
            % Syntax:
            %   out = text(obj)
            % ----------------------------------------------------------
            if isempty(obj)
                out = sprintf("Empty %sCollection", string(obj.recordType));
                return
            end

            out = "";
            for i = 1:obj.Count
                out = out + obj.Records(i).Primitive.text(); % TODO
            end
        end

        function out = code(obj, collectionVarName)
            arguments
                obj
                collectionVarName    (1,1)  string = "value"
            end

            if obj.Count == 0
                out = "";
                return
            end

            out = "";
            for i = 1:obj.Count
                out = out + obj.Records(i).code(collectionVarName);
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
            % ----------------------------------------------------------
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

    methods (Access = {?aod.schema.Schema})
        function setParent(obj, parent)
            if nargin < 2 || isempty(parent)
                obj.Parent = [];
                return
            end

            mustBeSubclass(parent, ["aod.core.Entity", "aod.persistent.Entity"]);

            obj.Parent = parent;
        end
    end


    % MATLAB builtin methods
    methods
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
            % ----------------------------------------------------------
            groupName = string(obj.recordType)+"s";

            S = struct();
            S.(groupName) = struct();

            if isempty(obj)
                return
            end

            for i = 1:obj.Count
                S.(groupName) = catstruct(S.(groupName), obj.Records(i).struct());
            end
        end
    end
end