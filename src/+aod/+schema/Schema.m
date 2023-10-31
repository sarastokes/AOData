classdef (Abstract) Schema < handle

    properties (SetAccess = private)
        Parent
        className       (1,1)       string
    end

    properties (Hidden, Access = protected)
        DatasetCollection
        AttributeCollection
        FileCollection
    end

    % Separating access and storage enables dynamic schema creation for
    % the core interface and lazy loading for the persistent interface
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
                schemaTypes = ["attribute", "dataset", "file"];
                for i = 1:3
                    tf = obj.has(recordName, schemaTypes(i));
                    if tf
                        return
                    end
                end
            end
        end

        function out = getSchemaByType(obj, schemaType)
            switch lower(schemaType)
                case {'attribute', 'attributes', 'attr', 'attrs'}
                    out = obj.Attributes;
                case {'dataset', 'datasets', 'dset', 'dsets'}
                    out = obj.Datasets;
                case {'file', 'files'}
                    out = obj.Files;
                otherwise
                    error('getSchemaType:UnknownSchemaType',...
                        'Schema type %s was unrecognized; use datasets, attributes or files', schemaType);
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
            obj.className = string(class(parent));
        end
    end

    methods
        function checkForUndefined(obj)
            % TODO: Quickly access primitive types
        end

        function [tf, ME] = checkSchemaIntegrity(obj, schemaType, entryName)
            if nargin > 1
                schema = obj.getSchemaByType(schemaType);
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
            if ~isempty(datasetSchema)
                [tfDset, dsetME] = dsetSchema.checkIntegrity();
            end

            tf = all([tfFile, tfAttr, tfDset]);
            if ~tf
                ME = MException("checkSchemaIntegrity:InconsistenciesFound",...
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

        function [tf, ME, excObj] = validate(obj, schemaType, entryName)
            if ~aod.util.isempty(schemaType)
                switch schemaType
                    case "dataset"
                        [tf, ME] = obj.validateDataset(entryName);
                end
            end
            % TODO: Finish writing
        end


        function out = text(obj)
            % TODO persistent schema text display
            out = "Not yet implemented";
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

    % MATLAB builtin methods
    methods
        function S = struct(obj)
            entityName = strrep(obj.className, '.', '__'); % TODO
            if ~isempty(obj.Parent)
                entityType = string(obj.Parent.entityType);
                entityClass = string(getClassWithoutPackages(obj.Parent));
                packageName = erase(string(class(obj.Parent)), "." + entityClass);
                superNames = string(superclasses(obj.Parent));
                superNames = superNames(1:find(superNames == "aod.core.Entity"));
            else
                entityType = []; entityClass = [];
                packageName = []; superNames = [];
            end
            S = struct();
            S.(entityName).ClassName = entityClass;
            S.(entityName).PackageName = packageName;
            S.(entityName).EntityType = entityType;
            S.(entityName).Superclasses = superNames';
            S.(entityName) = catstruct(S.(entityName), obj.Attributes.struct());
            S.(entityName) = catstruct(S.(entityName), obj.Datasets.struct());
            S.(entityName) = catstruct(S.(entityName), obj.Files.struct());
        end
    end
end