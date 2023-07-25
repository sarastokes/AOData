classdef DefaultValue < aod.specification.Validator
% Specifies a default value for a property
%
% Superclasses:
%   aod.specification.Validator
%
% Constructor:
%   aod.specification.DefaultValue(input)
%
% TODO: Should this be a "validator"?

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Value           = []
    end

    methods
        function obj = DefaultValue(input, parent)
            if nargin < 2
                parent = [];
            end
            obj = obj@aod.specification.Validator(parent);

            if nargin > 0
                obj.setValue(input);
            end
        end
    end

    methods
        function setValue(obj, input)
            if isa(input, 'meta.property')
                if input.HasDefault
                    obj.Value = input.DefaultValue;
                end
            elseif istext(input) && input == "[]"
                obj.Value = [];
            else
                obj.Value = input;
            end
        end

        function tf = validate(~, ~)
            tf = true;
        end

        function out = text(obj)
            out = value2string(obj.Value);
            out = convertCharsToStrings(out);
        end
    end

    % MATLAB built-in methods
    methods
        function tf = isempty(obj)
            tf = aod.util.isempty(obj.Value);
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