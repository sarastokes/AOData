classdef Count < aod.specification.Validator
% COUNT
%
% Superclasses:
%   aod.specification.Validator
%
% Constructor:
%   obj = aod.schema.validators.Count(parent, value)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Value       double      {mustBeInteger, mustBeScalarOrEmpty} = []
    end

    methods
        function obj = Count(parent, value)
            arguments
                parent      {mustBeScalarOrEmpty}   = []
                value       {mustBeInteger}         = []
            end
            obj = obj@aod.specification.Validator(parent);
            if nargin > 1 && ~isempty(value)
                obj.setValue(value);
            end
        end

        function setValue(obj, value)
            if aod.util.isempty(value)
                obj.Value = [];
                return
            end

            obj.Value = value;
        end

        function [tf, ME] = validate(obj, input)
            tf = true; ME = [];

            if aod.util.isempty(input) || isempty(obj)
                return
            end

            if numel(input) ~= obj.Value
                tf = false;
                ME = MException('validate:InvalidCount',...
                    'Expected count to be %u, was %u', obj.Value, numel(input));
            end
        end

        function out = text(obj)
            if isempty(obj)
                out = "[]";
            else
                out = string(num2str(obj));
            end
        end
    end

    methods
        function tf = isempty(obj)
            tf = isempty(obj.Value);
        end

        function out = jsonencode(obj)
            if isempty(obj)
                out = "[]";
            else
                out = jsonencode(obj.Value);
            end
        end
    end
end