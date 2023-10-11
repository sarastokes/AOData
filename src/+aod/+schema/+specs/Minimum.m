classdef Minimum < aod.specification.Validator
% MINIMUM - An inclusive minimum specification
%
% Superclasses:
%   aod.specification.Validator
%
% Constructor:
%   obj = aod.schema.specs.Minimum(parent, value)
%
%

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Value           {mustBeScalarOrEmpty, mustBeNumeric} = []
    end

    methods
        function obj = Minimum(parent, value)
            arguments
                parent      {mustBeScalarOrEmpty}                   = []
                value       {mustBeScalarOrEmpty, mustBeNumeric}    = []
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