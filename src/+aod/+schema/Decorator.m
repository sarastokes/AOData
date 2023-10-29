classdef (Abstract) Decorator < aod.schema.Specification
% (Abstract) Parent class for metadata decorators
%
% Description:
%   Decorators describe the data but are not used in validation
%
% See also:
%   aod.schema.Specification

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties
        Value              string = string.empty()
    end

    methods
        function obj = Decorator(parent)
            if nargin == 0
                parent = [];
            end
            obj = obj@aod.schema.Specification(parent);
        end
    end

    methods
        function out = text(obj)
            if all(aod.util.isempty(obj.Value))
                out = "[]";
            else
                out = value2string(obj.Value);
            end
        end

        function tf = isSpecified(obj)
            tf = ~aod.util.isempty(obj.Value);
        end
    end

    % MATLAB built-in methods
    methods
        function tf = isequal(obj, other)
            if ~isa(other, class(obj))
                tf = false;
                return
            end
            tf = isequal(obj.Value, other.Value);
        end
    end
end