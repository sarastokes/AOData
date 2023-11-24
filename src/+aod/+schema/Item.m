classdef Item < aod.schema.Record

    properties (Hidden, SetAccess = protected)
        SCHEMA_OBJECT_TYPE             = aod.schema.SchemaTypes.ITEM
    end

    methods
        function obj = Item(parent, name, type, varargin)
            obj@aod.schema.Record(parent, name, type, varargin{:});
        end
    end

    methods (Access = protected)
        function setParent(obj, parent)
            arguments
                obj
                parent          aod.schema.Record
            end

            obj.Parent = parent;
        end
    end
end