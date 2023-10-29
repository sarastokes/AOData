classdef Length < aod.schema.Validator
%
% Superclasses:
%   aod.schema.Validator
%
% Description:
%   Validates the length of a string
%
% Constructor:
%   obj = aod.schema.validators.Length(value)

% By Sara Patterson, 2023 (AOData)
% --------------------------------------------------------------------------

    properties (SetAccess = private)
        Value       double {mustBeInteger, mustBeScalarOrEmpty} = []
    end

    methods
        function obj = Length(parent, value)
            arguments
                parent      {mustBeScalarOrEmpty}   = []
                value       {mustBeScalarOrEmpty, mustBeInteger}   = []
            end
            obj = obj@aod.schema.Validator(parent);
            if ~isempty(value)
                obj.setValue(value);
            end
        end
    end

    methods
        function setValue(obj, value)
            if aod.schema.util.isInputEmpty(value)
                obj.Value = [];
            else
                obj.Value = value;
            end
        end

        function [tf, ME] = validate(obj, input)
            if ~obj.isSpecified()
                tf = true; ME = [];
                return
            end

            if ~isstring(input)
                tf = false;
                ME = MException('validate:InvalidClass',...
                    'Expected string not %s', class(input));
            else
                tf = all(arrayfun(@(x) isequal(strlength(x), obj.Value), input));
                if ~tf
                    ME = MException('validate:InvalidLength',...
                        'Expected %u length', obj.Value);
                else
                    ME = [];
                end
            end
        end

        function out = text(obj)
            if ~obj.isSpecified()
                out = "[]";
            else
                out = string(num2str(obj.Value));
            end
        end
    end
end