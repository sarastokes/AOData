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

    properties (SetAccess = protected)
        Value              string = string.empty()
    end

    properties (Hidden, SetAccess = protected)
        SCHEMA_OBJECT_TYPE          = aod.schema.SchemaObjectTypes.DECORATOR
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

    methods (Access = protected)
        function value = determineSchemaType(obj)
            if ~isempty(obj.Parent) && obj.Parent.isNested
                value = aod.schema.SchemaTypes.ITEM_DECORATOR;
            else
                value = aod.schema.SchemaTypes.DECORATOR;
            end
        end
    end
end