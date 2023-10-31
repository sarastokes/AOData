classdef Custom < aod.schema.Validator

    properties (SetAccess = private)
        Value
    end

    methods
        function obj = Custom(parent, value)
            obj = obj@aod.schema.Validator(parent);
            if nargin > 1
                obj.setValue(value);
            end
        end
    end

    methods
        function setValue(obj, value)
            obj.Value = value;
        end
    end
end