classdef Schema < aod.schema.Schema

    methods
        function obj = Schema(parent)
            obj = obj@aod.schema.Schema(parent);
        end
    end

    methods (Access = protected)
        function value = getDatasetCollection(obj)
            obj.DatasetCollection = aod.schema.collections.DatasetCollection.populate(class(obj.Parent));
            obj.DatasetCollection.setParent(obj.Parent);  % TODO
            value = obj.Parent.specifyDatasets(obj.DatasetCollection);
        end

        function value = getFileCollection(obj)
            value = obj.Parent.specifyFiles();
            value.setClassName(class(obj.Parent));
            value.setParent(obj.Parent);
        end

        function value = getAttributeCollection(obj)
            value = obj.Parent.specifyAttributes();
            value.setClassName(class(obj.Parent));
            value.setParent(obj.Parent);
        end
    end
end