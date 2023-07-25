classdef Maximum < aod.specification.Validator
% Specifies a maximum (inclusive) value for a property.
%
% Superclasses:
%   aod.specification.Validator
%
% Constructor:
%   aod.specification.Maximum(value)
%
% See also:
%   aod.specification.Minimum

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Value           {mustBeNumeric} = []
    end

    methods
        function obj = Maximum(value, parent)
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
            if obj.isInputEmpty(input)
                obj.Value = [];
            elseif ~isa(input, 'meta.property')
                obj.Value = input;
            end
        end

        function tf = validate(obj, input)
            if obj.isempty()
                tf = true;
            else
                tf = all(input <= obj.Value);
            end
        end

        function out = text(obj)
            if obj.isempty()
                out = "[]";
            else
                out = value2string(obj.Value);
            end
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