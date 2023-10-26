classdef Units < aod.schema.Decorator
%
% Superclasses:
%   aod.schema.Decorator
%
% Constructor:
%   obj = aod.schema.decorators.Units(parent, value)
%

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    methods
        function obj = Units(parent, value)
            obj = obj@aod.schema.Decorator(parent);
            if ~aod.util.isempty(value)
                obj.setValue(value);
            end
        end
    end

    methods
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
            if ~obj.isSpecified
                out = "[]";
            else
                out = value2string(obj.Value);
            end
        end
    end

    methods
        function tf = isSpecified(obj)
            tf = ~aod.util.isempty(obj.Value);
        end
    end
end