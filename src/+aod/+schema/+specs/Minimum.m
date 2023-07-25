classdef Minimum < aod.specification.Validator

    properties (SetAccess = private)
        Value           {mustBeNumeric} = []
    end

    methods
        function obj = Minimum(value, parent)
            arguments 
                value       {mustBeNumeric}         = []
                parent      {mustBeScalarOrEmpty}   = []
            end

            obj = obj@aod.specification.Validator(parent);
            if ~isempty(value)
                obj.setValue(value);
            end
        end
    end

    methods
        function setValue(obj, input)
            if istext(input) && input == "[]"
                obj.Value = [];
            elseif ~isa(input, 'meta.property')
                obj.Value = input;
            end
        end

        function tf = validate(obj, input)
            tf = all(input >= obj.Value);
        end

        function out = text(obj)
            out = value2string(obj.Value);
            out = convertCharsToStrings(out);
        end
    end

    % MATLAB builtin methods
    methods
        function tf = isempty(obj)
            tf = isempty(obj.Value);
        end

        function out = jsonencode(obj)
            if isempty(obj)
                out = jsonencode([]);
            else
                out = jsonencode(obj.Value);
            end
        end
    end
end