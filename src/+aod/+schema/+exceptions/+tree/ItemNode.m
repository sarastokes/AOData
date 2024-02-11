classdef ItemNode < aod.schema.exceptions.tree.ExceptionNode
% ITEMNODE
%
% Description:
%   Represents an Item within a Record with a Container (aka a
%   Primitive that contains other Primitives)
%
% See also:
%   aod.schema.Container, aod.schema.Item

    properties (SetAccess = private)
        Name                    string
        primitiveType           aod.schema.PrimitiveTypes
    end

    methods
        function obj = ItemNode(item, varargin)
            obj = obj@aod.schema.exceptions.tree.ExceptionNode(varargin{:});

            obj.Name = item.Name;
            obj.primitiveType = item.primitiveType;
        end
    end

    methods
        function addChildren(obj, children)  %#ok<INUSD>
            if ~isempty(children)
                error('ItemNode:addChildren', 'ItemNode cannot have child nodes');
            end
        end
    end

    methods
        function out = text(obj, indentLevel)
            arguments
                obj
                indentLevel   (1,1)  double {mustBeInteger, mustBeNonnegative} = obj.SCHEMA_LEVEL
            end

            indent = obj.getIndent(indentLevel);

            if obj.totalNumErrors == 0
                out = "";
                return
            end

            out = sprintf("%s%s (%s)\n", indent, obj.Name, string(obj.primitiveType));
            for i = 1:numel(obj.Causes)
                out = out + sprintf("%s! %s\n", indent + 4, obj.Causes(i).Message);
            end
        end
    end
end