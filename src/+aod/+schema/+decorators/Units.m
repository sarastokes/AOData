classdef Units < aod.specification.Decorator
%
% Superclasses:
%   aod.specification.Decorator
%
% Constructor:
%   obj = aod.schema.decorators.Units(parent, value)
%

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties
        Value       string      = ""
    end

    methods
        function obj = Units(parent, value)
            obj = obj@aod.specification.Decorator(parent);
            if ~aod.util.isempty(value)
                obj.setValue(value);
            end
        end

        function setValue(obj, input)
            arguments
                obj
                input       string      = ""
            end

            if ~aod.util.isempty(input)
                mustBeVector(input);
            end
            if numel(input) > 1 && iscolumn(input)
                input = input';
            end

            obj.Value = input;
        end

        function out = text(obj)
            if aod.util.isempty(obj)
                out = "[]";
            else
                out = value2string(obj.Value);
            end
        end
    end

    methods
        function tf = isempty(obj)
            tf = aod.util.isempty(obj.Value);
        end
    end
end