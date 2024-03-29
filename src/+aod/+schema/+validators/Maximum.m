classdef Maximum < aod.schema.Validator
% Specifies a maximum (inclusive) value for a property.
%
% Superclasses:
%   aod.schema.Validator
%
% Constructor:
%   aod.specification.Maximum(value)
%
% See also:
%   aod.specification.Minimum

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Value           {mustBeScalarOrEmpty, mustBeNumeric}        = []
    end

    methods
        function obj = Maximum(parent, value)
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
            if aod.schema.util.isInputEmpty(input)
                obj.Value = [];
            elseif ~isa(input, 'meta.property')
                obj.Value = input;
            end
        end

        function [tf, ME] = validate(obj, input)
            ME = [];
            if ~obj.isSpecified()
                tf = true;
            else
                tf = all(input <= obj.Value);
                if ~tf
                    ME = MException('validate:MaximumExceeded',...
                        'Value exceeds maximum of %s', num2str(obj.Value));
                end
            end
        end

        function out = text(obj)
            if ~obj.isSpecified()
                out = "[]";
            else
                out = value2string(obj.Value);
            end
            out = convertCharsToStrings(out);
        end
    end

    % MATLAB builtin functions
    methods
        function tf = isequal(obj, other)
            if ~isa(other, 'aod.schema.validators.Maximum')
                tf = false;
                return
            end

            tf = isequal(obj.Value, other.Value);
        end
    end
end