classdef Minimum < aod.schema.Validator
% MINIMUM - An inclusive minimum specification
%
% Superclasses:
%   aod.schema.Validator
%
% Constructor:
%   obj = aod.schema.validators.Minimum(parent, value)
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

            obj = obj@aod.schema.Validator(parent);
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

        function [tf, ME] = validate(obj, input)
            ME = [];
            if ~obj.isSpecified
                tf = true;
            else
                tf = all(input >= obj.Value);
                if ~tf
                    ME = MException('validate:MinimumExceeded',...
                        'Value was lower than Minimum of %s', num2str(obj.Value));
                end
            end
        end

        function out = text(obj)
            out = value2string(obj.Value);
            out = convertCharsToStrings(out);
        end
    end

    % MATLAB builtin functions
    methods
        function tf = isequal(obj, other)
            if ~isa(other, 'aod.schema.validators.Minimum')
                tf = false;
                return
            end

            tf = isequal(obj.Value, other.Value);
        end
    end
end