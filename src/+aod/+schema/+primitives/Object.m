classdef Object < aod.schema.primitives.Container

    properties (Hidden, SetAccess = protected)
        PRIMITIVE_TYPE = aod.schema.primitives.PrimitiveTypes.OBJECT
        OPTIONS = ["Size", "Items", "Default", "Description"];
        VALIDATORS = ["Class", "Size"] % FIELDS
    end

    methods
        function obj = Object(name, parent, varargin)
            obj = obj@aod.schema.primitives.Container(name, parent);

            % Default values
            obj.setClass("cell");

            % Complete setup and ensure schema consistency
            obj.parseInputs(varargin{:});
            obj.isInitializing = false;
            obj.checkIntegrity(true);
        end
    end

    methods
        function addItem(obj, newItem)
            addItem@aod.schema.primitives.Container(obj, newItem);

            if ~obj.Size.isSpecified()
                obj.setSize(sprintf("(:,%u", obj.numItems));
            else
                obj.Size.Value(2).setValue(obj.numItems);
            end
        end

        function removeItem(obj, ID)
            removeItem@aod.schema.primitives.Container(obj, ID);
            if obj.numItems == 0
                obj.Size.Value(2) = aod.schema.validators.size.UnrestrictedDimension();
            else
                obj.Size.Value(2).setValue(obj.Count);
            end
        end
    end

    methods (Access = protected)
        function p = createPrimitive(obj, type, varargin)
            name = sprintf('%s_%u', obj.Name, obj.numItems+1);
            p = createPrimitive@aod.schema.primitives.Container(obj,...
                type, name, varargin{:});
        end
    end
end
