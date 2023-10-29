classdef Schema < handle

    properties (SetAccess = private)
        Parent          % aod.persistent.Entity
    end

    properties
        Datasets        aod.schema.collections.DatasetCollection
        Attributes      aod.schema.collections.AttributeCollection
        Files           aod.schema.collections.FileCollection
    end

    methods
        function obj = Schema(parent)
            obj.setParent(parent);

            % Initialize
            obj.Datasets = aod.schema.collections.DatasetCollection(obj.Parent);
            obj.Attributes = aod.schema.collections.AttributeCollection(obj.Parent);
            obj.Files = aod.schema.collections.FileCollection(obj.Parent);

            % Populate the three schema collections
            obj.collectSchemas()
        end
    end

    methods
        function out = text(obj)
            % TODO persistent schema text display
            out = "Not yet implemented";
        end
    end

    methods (Access = private)
        function obj = collectSchemas(obj)
            out = h5read(obj.Parent.hdfName,...
                h5tools.util.buildPath(obj.Parent.hdfPath, 'Schema'));
            S = jsondecode(out);
            fMain = string(fieldnames(S));

            obj.Datasets = aod.h5.readSchemaCollection(S.(fMain).Datasets, obj.Datasets);
            obj.Attributes = aod.h5.readSchemaCollection(S.(fMain).Attributes, obj.Attributes);
            obj.Files = aod.h5.readSchemaCollection(S.(fMain).Files, obj.Files);
        end

        function setParent(obj, parent)
            arguments
                obj
                parent          aod.persistent.Entity
            end

            obj.Parent = parent;
        end
    end
end