classdef (Abstract) AODataSchemaObject < handle

    properties (Abstract, Hidden, SetAccess = protected)
        SCHEMA_OBJECT_TYPE          aod.schema.SchemaObjectTypes
    end

    methods
        function obj = AODataSchemaObject()
            % Do nothing
        end
    end

    methods
        function getParent(obj, parentType)
            parentType = aod.schema.SchemaObjectTypes.get(parentType);

            parent = obj.Parent;
            while ~isSubclass(parent, parentType)
                parent = parent.Parent;
                if isempty(parent)
                    break
                end
            end
        end
    end
end