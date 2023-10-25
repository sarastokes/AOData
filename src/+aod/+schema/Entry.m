classdef Entry < handle
% This is where primitive type changes would be handled

    properties (SetAccess = private)
        Parent                  % aod.schema.SchemaCollection
        Primitive               % aod.schema.primitives.Primitive
    end

    properties (Dependent)
        Name            (1,1)   string
        className       (1,1)   string
        primitiveType   (1,1)   aod.schema.primitives.PrimitiveTypes
        ParentPath      (1,1)   string
    end

    methods
        function obj = Entry(parent, name, type, varargin)
            if isobject(parent) || ~isempty(parent)
                obj.setParent(parent);  % empty parent support for testing
            end

            obj.Primitive = aod.schema.util.createPrimitive(...
                type, name, obj, varargin{:});
        end

        function value = get.Name(obj)
            if isempty(obj.Primitive)
                value = [];
            else
                value = obj.Primitive.Name;
            end
        end

        function value = get.primitiveType(obj)
            value = obj.Primitive.PRIMITIVE_TYPE;
        end

        function value = get.ParentPath(obj) %#ok<MANU>
            value = ""; % TODO: implement parent identifier
        end

        function value = get.className(obj)
            if isobject(obj.Parent)
                value = obj.Parent.className;
            else
                value = "";
            end
        end

        function p = getPrimitive(obj)
            p = obj.Primitive;
        end
    end

    methods
        function setType(obj, primitiveType)
            primitiveType = aod.schema.primitives.PrimitiveTypes.get(primitiveType);
            if isequal(obj.primitiveType, primitiveType)
                return
            end
            newPrimitive = aod.schema.util.createPrimitive(...
                primitiveType, obj.Name, obj);
            obj.Primitive = newPrimitive;
        end

        function assign(obj, varargin)
            obj.Primitive.assign(varargin{:});
        end

        function [tf, ME] = validate(obj, input, errorType)
            if nargin < 3
                errorType = aod.infra.ErrorTypes.ERROR;
            else
                errorType = aod.infra.ErrorTypes.get(errorType);
            end
            [tf, ME] = obj.Primitive.validate(input, errorType);
        end
    end

    methods (Access = private)
        function setParent(obj, parent)
            arguments
                obj
                parent      {mustBeSubclass(parent, 'aod.schema.SchemaCollection')}
            end

            obj.Parent = parent;
        end
    end

    % MATLAB builtin functions
    methods
        function tf = isequal(obj, other)
            if ~isa(other, class(obj))
                tf = false;
            else
                tf = isequal(obj.getPrimitive(), other.getPrimitive());
            end
        end
    end
end