classdef EntitySchema < handle
% TODO: distinct schema classes for core vs. persistent
% TODO: requirements reporting

    properties (SetAccess = private)
        Parent      % aod.core.Entity
    end

    properties (Dependent)
        Datasets
        Attributes
        Files
        className
    end

    properties (Hidden, Access = private)
        DatasetCollection
    end

    methods
        function obj = EntitySchema(parent)
            obj.setParent(parent);
            obj.DatasetCollection = aod.schema.collections.DatasetCollection.populate(class(obj.Parent));
            obj.DatasetCollection.setParent(obj.Parent);
        end
        
        function value = get.className(obj)
            if isempty(obj.Parent)
                value = "";
            else
                value = string(class(obj.Parent));
            end
        end

        function value = get.Datasets(obj)
            value = obj.Parent.specifyDatasets(obj.DatasetCollection);
        end

        function value = get.Files(obj)
            value = obj.Parent.specifyFiles();
            value.setClassName(class(obj.Parent));
            value.setParent(obj.Parent);
        end

        function value = get.Attributes(obj)
            value = obj.Parent.specifyAttributes();
            value.setClassName(class(obj.Parent));
            value.setParent(obj.Parent);
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

        function [tf, ME] = validate(obj, schemaType, entryName)
            

        end

        function [tf, ME] = validateDataset(obj, dsetName)
            schema = obj.Datasets.get(dsetName);
            [tf, ME] = schema.validate(obj.Parent.(dsetName));
        end

        function [tf, ME] = validateAttribute(obj, attrName)
            schema = obj.Attributes.get(attrName);
            [tf, ME] = schema.validate(obj.Parent.getAttr(attrName));
        end

        function [tf, ME] = validateFile(obj, fileName)
            schema = obj.Files.get(fileName);
            [tf, ME] = schema.validate(obj.Parent.getFile(fileName));
        end
    end

    methods (Access = protected)
        function setParent(obj, parent)
            if ~isempty(parent)
                mustBeA(parent, 'aod.core.Entity');
            end
            obj.Parent = parent;
        end
    end
end