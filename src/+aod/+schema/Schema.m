classdef (Abstract) Schema < aod.schema.AODataSchemaObject
% SCHEMA (abstract)
%
% Description:
%   Defines common interface for schema representation
%
% Notes:
%   Separating access and storage of collections enables dynamic schema
%   creation for core interface and lazy loading for persistent interface

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Parent
    end

    properties (SetAccess = protected)
        className               string
        classUUID               string
        entityType
    end

    properties (Hidden, Access = protected)
        DatasetCollection
        AttributeCollection
        FileCollection
    end

    properties (Dependent)
        Datasets
        Attributes
        Files
    end

    methods (Abstract, Access = protected)
        value = getDatasetCollection(obj);
        value = getAttributeCollection(obj);
        value = getFileCollection(obj);
    end

    methods
        function obj = Schema(parent)
            obj.setParent(parent);
        end
    end

    % Dependent set/get methods
    methods
        function value = get.Datasets(obj)
            value = obj.getDatasetCollection();
        end

        function value = get.Attributes(obj)
            value = obj.getAttributeCollection();
        end

        function value = get.Files(obj)
            value = obj.getFileCollection();
        end
    end

    methods
        function tf = has(obj, recordName, recordType)
            if nargin == 3
                collection = obj.getSchemaByType(recordType);
                tf = collection.has(recordName);
            else
                recordTypes = ["attribute", "dataset", "file"];
                for i = 1:3
                    tf = obj.has(recordName, recordTypes(i));
                    if tf
                        return
                    end
                end
            end
        end

        function out = getSchemaByType(obj, recordType)
            switch lower(recordType)
                case {'attribute', 'attributes', 'attr', 'attrs'}
                    out = obj.Attributes;
                case {'dataset', 'datasets', 'dset', 'dsets'}
                    out = obj.Datasets;
                case {'file', 'files'}
                    out = obj.Files;
                otherwise
                    error('getRecordType:UnknownRecordType',...
                        'Schema type %s was unrecognized; use datasets, attributes or files', recordType);
            end
        end
    end

    methods (Access = protected)
        function setParent(obj, parent)
            if isempty(parent)
                obj.className = "UNDEFINED";  % TODO For testing
                return
            end

            mustBeSubclass(parent, ["aod.core.Entity", "aod.persistent.Entity"]);
            obj.Parent = parent;
            obj.setClassName(class(parent));
        end
    end

    methods
        function [counts, dsetNames, attrNames, fileNames] = checkForUndefined(obj, errorType)
            arguments
                obj
                errorType       = aod.infra.ErrorTypes.WARNING
            end

            errorType = aod.infra.ErrorTypes.init(errorType);

            dsetNames = obj.Datasets.checkForUndefined();
            attrNames = obj.Attributes.checkForUndefined();
            fileNames = obj.Files.checkForUndefined();

            counts = [numel(dsetNames), numel(attrNames), numel(fileNames)];
            if errorType == aod.infra.ErrorTypes.NONE
                return
            end

            ME = MException('Schema:checkForUndefined:UndefinedRecordsExist',...
                '%s - %u datasets, %u attributes, %u files',...
                    obj.className, counts);
            if errorType == aod.infra.ErrorTypes.WARNING
                throwWarning(ME);
            else
                throw(ME);
            end
        end

        function [tf, ME] = checkSchemaIntegrity(obj, recordType, entryName)
            if nargin > 1
                schema = obj.getSchemaByType(recordType);
                p = schema.get(entryName, aod.infra.ErrorTypes.ERROR);
                [tf, ME] = p.checkSchemaIntegrity();
                return
            end

            fileSchema = obj.Files;
            if ~isempty(fileSchema)
                [tfFile, fileME] = fileSchema.checkIntegrity();
            end
            attrSchema = obj.Attributes;
            if ~isempty(attrSchema)
                [tfAttr, attrME] = attrSchema.checkIntegrity();
            end
            dsetSchema = obj.Datasets;
            if ~isempty(dsetSchema)
                [tfDset, dsetME] = dsetSchema.checkIntegrity();
            end

            tf = all([tfFile, tfAttr, tfDset]);
            if ~tf
                ME = MException(...
                    "checkSchemaIntegrity:InconsistenciesFound",...
                    "Inconsistent schemas in %u datasets, %u attributes and %u files",...
                    numel(dsetME.cause), numel(attrME.cause), numel(fileME.cause));

                for i = 1:numel(dsetME.cause)
                    ME = addCause(ME, dsetME.cause{i});
                end
                for i = 1:numel(attrME.cause)
                    ME = addCause(ME, dsetME.cause{i});
                end
                for i = 1:numel(fileME.cause)
                    ME = addCause(ME, fileME.cause{i});
                end
            end
        end

        function [tf, ME, excObj] = validate(obj, recordType, entryName)
            if ~aod.util.isempty(recordType)
                switch recordType
                    case "dataset"
                        [tf, ME] = obj.validateDataset(entryName);
                end
            end
            % TODO: Finish writing
        end

        function [datasets, attributes, files, ME] = getUndefined(obj, errorType)
            arguments
                obj
                errorType           = aod.infra.ErrorTypes.WARNING
            end

            errorType = aod.infra.ErrorTypes.init(errorType);

            datasets = obj.Datasets.getUndefined();
            attributes = obj.Attributes.getUndefined();
            files = obj.Files.getUndefined();

            ME = MException("getUndefined:UndefinedRecordsExist",...
                sprintf("Undefined records exist in %u datasets, %u attributes and %u files",...
                    numel(datasets), numel(attributes), numel(files)));
            if numel(datasets) > 0
                ME = addCause(ME, MException(...
                    "getUndefined:UndefinedDatasetsExist",...
                    "Datasets: " + strjoin(datasets, ", ")));
            end
            if numel(attributes) > 0
                ME = addCause(ME, MException(...
                    "getUndefined:UndefinedAttributesExist",...
                    "Attributes: " + strjoin(attributes, ", ")));
            end

            if numel(files) > 0
                ME = addCause(ME, MException(...
                    "getUndefined:UndefinedFilesExist",...
                    "Files: " + strjoin(files, ", ")));
            end

            switch errorType
                case aod.infra.ErrorTypes.WARNING
                    throwWarning(ME);
                case aod.infra.ErrorTypes.ERROR
                    throw(ME);
            end
        end

        function out = text(obj)
            out = jsonencode(obj.struct(), "PrettyPrint", true);
        end

        function out = code(obj)
            if isempty(obj.Parent)
                superName = "UNKNOWN";  % For testing
            else
                superName = superclasses(obj.Parent);
                superName = superName{1};
            end

            out = sprintf("\tmethods (Static)\n");
            dsetCode = obj.Datasets.code();
            out = out + sprintf("\t\tfunction value = specifyDatasets(value)\n");
            out = out + sprintf("\t\t\tvalue = specifyDatasets@%s(value);\n", superName);
            out = out + dsetCode + sprintf("\t\tend\n\n");

            attrCode = obj.Attributes.code();
            out = out + sprintf("\t\tfunction value = specifyAttributes()\n");
            out = out + sprintf("\t\t\tvalue = specifyAttributes@%s();\n\n", superName);
            out = out + attrCode + sprintf("\t\tend\n\n");

            fileCode = obj.Files.code();
            out = out + sprintf("\t\tfunction value = specifyFiles()\n");
            out = out + sprintf("\t\t\tvalue = specifyFiles@%s();\n\n", superName);
            out = out + fileCode + sprintf("\t\tend\n");
            out = out + sprintf("\tend\n");
        end
    end

    methods (Access = protected)
        function setClassName(obj, className)
            if ~isSubclass(className, ["aod.core.Entity", "aod.persistent.Entity"])
                error('setClassName:InvalidClass',...
                    'Class %s is not a subclass of aod.core.Entity', className);
            end

            obj.className = className;
            obj.entityType = aod.common.EntityTypes.getFromSuperclass(obj.className);
            obj.classUUID = aod.infra.UUID.getClassUUID(obj.className);
        end
    end

    % MATLAB builtin methods
    methods
        function tf = isequal(obj, other)
            if ~isa(other, 'aod.schema.Schema')
                tf = false;
                return
            end

            % Are they schemas for the same class?
            if ~isequal(obj.className, other.className)
                tf = false;  % TODO aliases
                return
            end

            % Defer to isequal defined by SchemaCollection
            if ~isequal(obj.Datasets, other.Datasets) ...
                    || ~isequal(obj.Attributes, other.Attributes) ...
                    || ~isequal(obj.Files, other.Files)
                tf = false;
                return
            end

            tf = true;
        end

        function S = struct(obj)
            if ~aod.util.isempty(obj.className)
                entityClass = getClassWithoutPackages(obj.className);
                packageName = erase(obj.className, "." + entityClass);
                superNames = string(superclasses(obj.className));
                superNames = superNames(1:find(superNames == "aod.core.Entity"));
            else
                packageName = []; superNames = []; entityClass = [];
            end

            S = struct();
            S.Name = obj.className;
            S.ClassName = entityClass;
            S.PackageName = packageName;
            S.EntityType = char(obj.entityType);
            S.Superclasses = superNames';
            % TODO: Aliases, UUIDs and version number
            S.VersionNumber = [];
            S.Aliases = [];
            S.UUID = obj.classUUID;
            % Leave blank until saved
            S.DateCreated = [];

            S = catstruct(S, obj.Attributes.struct());
            S = catstruct(S, obj.Datasets.struct());
            S = catstruct(S, obj.Files.struct());
        end
    end
end