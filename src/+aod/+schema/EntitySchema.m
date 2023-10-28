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
    end

    properties (Hidden, Access = private)
        DatasetCollection
    end

    methods
        function obj = EntitySchema(parent)
            obj.setParent(parent);
            obj.DatasetCollection = aod.schema.collections.DatasetCollection.populate(class(obj.Parent));
        end

        function value = get.Datasets(obj)
            value = obj.Parent.specifyDatasets(obj.DatasetCollection);
        end

        function value = get.Files(obj)
            value = obj.Parent.specifyFiles();
            value.setClassName(class(obj.Parent));
        end

        function value = get.Attributes(obj)
            value = obj.Parent.specifyAttributes();
            value.setClassName(class(obj.Parent));
        end

        function out = getSchemaByType(obj, schemaType)
            switch lower(schemaType)
                case 'attribute'
                    out = obj.Attributes;
                case 'dataset'
                    out = obj.Datasets;
                case 'file'
                    out = obj.Files;
            end
        end

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