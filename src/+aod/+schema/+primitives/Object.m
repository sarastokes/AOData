classdef Object < aod.schema.primitives.Container

    properties (Hidden, SetAccess = protected)
        PRIMITIVE_TYPE = aod.schema.primitives.PrimitiveTypes.OBJECT
        OPTIONS = ["Size", "Fields", "Default", "Description"];
        VALIDATORS = ["Size"] % FIELDS
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

        function setClass(obj, className)
            arguments
                obj 
                className       string
            end
            
            obj.setClass(value);
        end
    end

end
