classdef Length < aod.specification.Validator
%
% Superclasses:
%   aod.specification.Validator
%
% Description:
%   Validates the length of a string
%
% Constructor:
%   obj = aod.schema.specs.Length(value)

% By Sara Patterson, 2023 (AOData)
% --------------------------------------------------------------------------

    properties (SetAccess = private)
        Value       double {mustBeInteger, mustBeScalarOrEmpty} = []
    end

    methods
        function obj = Length(parent, value)
            arguments
                parent      {mustBeScalarOrEmpty}   = []
                value       {mustBeInteger}         = []
            end
            obj = obj@aod.specification.Validator(parent);
            if ~isempty(value)
                obj.setValue(value);
            end
        end
    end

    methods
        function setValue(obj, value)
            if obj.isInputEmpty(value)
                obj.Value = [];
            else
                obj.Value = value;
            end
        end

        function [tf, ME] = validate(obj, input)
            if obj.isempty()
                tf = true; ME = [];
                return
            end

            if ~isstring(input)
                tf = false;
                ME = MException('validate:InvalidClass',...
                    'Expected string not %s', class(input));
            else
                tf = all(strlength(input) == obj.Value);
                if ~tf
                    ME = MException('validate:InvalidLength',...
                        'Expected %u length', obj.Value);
                else
                    ME = [];
                end
            end
        end

        function out = text(obj)
            if obj.isempty()
                out = "[]";
            else
                out = string(num2str(obj.Value));
            end
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