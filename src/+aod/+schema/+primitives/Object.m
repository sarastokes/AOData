classdef Object < aod.schema.primitives.Container
% TODO: Should Count be included?? Survey "isRequired" to determine?

    properties (SetAccess = private)
        Count               aod.schema.validators.Count
    end

    properties (Hidden, SetAccess = protected)
        PRIMITIVE_TYPE = aod.schema.primitives.PrimitiveTypes.OBJECT
        OPTIONS = ["Class", "Items", "Default", "Description"];
        VALIDATORS = ["Class", "Count"];
    end

    methods
        function obj = Object(name, parent, varargin)
            obj = obj@aod.schema.primitives.Container(name, parent);

            % Initialize
            obj.Count = aod.schema.validators.Count([], obj);

            % Complete setup and ensure schema consistency
            obj.parseInputs(varargin{:});
            obj.isInitializing = false;
            obj.checkIntegrity(true);
        end
    end

    methods
        function determineCount(obj)
            if obj.numItems == 0
                obj.Count.setValue([]);
            else
                % TODO: Determine which have "isRequired"
            end
        end
    end
end