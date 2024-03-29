classdef Object < aod.schema.Container
% TODO: Should Count be included?? Survey "Required" to determine?

    properties (SetAccess = private)
        Count               aod.schema.validators.Count
    end

    properties (Hidden, SetAccess = protected)
        PRIMITIVE_TYPE = aod.schema.PrimitiveTypes.OBJECT
        OPTIONS = ["Class", "Items", "Count", "Default", "Description"];
        VALIDATORS = ["Class", "Count"];
    end

    methods
        function obj = Object(parent, varargin)
            obj = obj@aod.schema.Container(parent);

            % Initialize
            obj.Count = aod.schema.validators.Count(obj, []);

            % Complete setup and ensure schema consistency
            obj.parseInputs(varargin{:});
            obj.isInitializing = false;
            obj.checkIntegrity(true);
        end
    end

    methods
        function setCount(obj, value)

            if aod.schema.util.isInputEmpty(value)
                obj.Count.setValue([]);
                return
            end

            mustBeInteger(value);
            if value < obj.numItems
                error('setCount:InvalidValue',...
                    'The count %u is below the number of specified items (%u)', value, obj.numItems);
            end

            obj.Count.setValue(value);
        end
    end

    methods
        function determineCount(obj)
            if obj.numItems == 0
                obj.Count.setValue([]);
            else
                % TODO: Determine which have "Required"
            end
        end
    end
end