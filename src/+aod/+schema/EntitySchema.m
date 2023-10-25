classdef EntitySchema < handle
% TODO: distinct schema classes for core vs. persistent

    properties (SetAccess = private)
        Parent      % aod.core.Entity
    end

    properties (Dependent)
        Datasets
        Attributes
        Files
    end

    properties %(Hidden, Access = private)
        DatasetCollection
    end

    methods
        function obj = EntitySchema(parent)
            obj.setParent(parent);
            obj.DatasetCollection = aod.schema.DatasetCollection.populate(class(obj.Parent));
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

        function tf = checkSchemaIntegrity(obj, entryName)
            fileSchema = obj.Files;
            if ~isempty(fileSchema)
                fileSchema.checkIntegrity();
            end
            attrSchema = obj.Attributes;
            if ~isempty(attrSchema)
                attrSchema.checkIntegrity();
            end
            dsetSchema = obj.Datasets;
            if ~isempty(datasetSchema)
                dsetSchema.checkIntegrity();
            end
        end

        function [tf, ME] = validate(obj, entryName)

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