classdef PrimitiveCollection < handle
% PRIMITIVECOLLECTION
%
% Description:
%   A collection of primitives accessible by their index.
%
% Superclasses:
%   handle

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        Parent
        Primitives
    end

    properties (Dependent)
        Count
    end

    methods
        function obj = PrimitiveCollection(parent)
            if nargin > 0
                obj.Parent = parent;
            end
        end
    end

    methods
        function value = get.Count(obj)
            value = numel(obj.Primitives);
        end
    end

    methods

        function tf = has(obj, ID)
            arguments
                obj
                ID          {mustBeInteger}
            end

            tf = arrayfun(@(x) x > 0 & x < obj.Count, ID);
        end

        function p = get(obj, ID)
            arguments
                obj
                ID     (1,1)     {mustBeInteger}
            end
            mustBeInRange(ID, 1, obj.Count);

            p = obj.Primitives(ID);
        end

        function add(obj, p)
            arguments
                obj     (1,1)   aod.schema.collections.PrimitiveCollection
                p               aod.schema.primitives.Primitive
            end

            obj.Primitives = [obj.Primitives; p];
        end

        function remove(obj, ID)
            arguments
                obj
                ID     (1,1)     {mustBeInteger}
            end

            mustBeInRange(ID, 1, obj.Count);
        end

        function set(obj, ID, varargin)
            arguments
                obj
                ID      (1,1)       {mustBeInteger}
            end

            arguments (Repeating)
                varargin
            end

            mustBeInRange(ID, 1, obj.Count);

            obj.Primitives(ID).assign(varargin{:});
        end

        function clear(obj)
            obj.Primitives = [];
        end
    end
end