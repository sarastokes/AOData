classdef Item < aod.schema.Record
% ITEM
%
% Description:
%   Wrapper for nested primitives. All interaction with contained primitive
%   is done through this class.
%
% Superclasses:
%   aod.schema.Record

    methods
        function obj = Item(parent, name, type, varargin)
            if all(~isletter(name))
                name = parent.name + "_" + name;
            end
            obj@aod.schema.Record(parent, name, type, varargin{:});
            obj.SCHEMA_OBJECT_TYPE = aod.schema.SchemaObjectTypes.ITEM;
        end
    end

    methods (Access = protected)
        function setParent(obj, parent)
            arguments
                obj
                parent          aod.schema.collections.ItemCollection
            end

            obj.Parent = parent;
        end

        function primitiveTypes = getAllowablePrimitiveTypes(obj)
            if isempty(obj.Parent) || isempty(obj.Parent.Parent)
                primitiveTypes = [];
                return
            end

            primitiveTypes = obj.Parent.Parent.ALLOWABLE_CHILD_TYPES;
        end
    end
end