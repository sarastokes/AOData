classdef Record < handle
% RECORD
%
% Description:
%   A wrapper for Primitive that ensures a consistent interface when
%   working with aod.common.Entity and schema collections. Having a wrapper
%   means that the primitive type can be changed in-place.
%
% Constructor:
%   obj = aod.schema.Record(parent, name, primitiveType, varargin)
%
% TODO: Name property is currently duplicated in Entry and child Primitive

% By Sara Patterson, 2023 (AOData)
% --------------------------------------------------------------------------

    properties (SetAccess = private)
        Name            (1,1)   string
        Parent                  % aod.schema.SchemaCollection
        Primitive               % aod.schema.primitives.Primitive
    end

    properties (Dependent)
        % TODO: isNested
        isRequired      (1,1)   logical
        className       (1,1)   string
        primitiveType   (1,1)   aod.schema.primitives.PrimitiveTypes
        ParentPath      (1,1)   string
    end

    methods
        function obj = Record(parent, name, type, varargin)
            if isobject(parent) || ~isempty(parent)
                obj.setParent(parent);  % empty parent support for testing
            end
            obj.setName(name);

            % Create the primitive and confirm that it is valid
            obj.Primitive = aod.schema.util.createPrimitive(...
                type, obj.Name, obj, varargin{:});
            if isobject(parent)
                obj.checkPrimitiveType();
            end
        end

        function value = get.isRequired(obj)
            value = obj.Primitive.isRequired;
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
            % SETTYPE  Assigns a primitive type to an entry
            %
            % Notes:
            %   Anything specified by the existing primitive is lost
            % -------------------------------------------------------------
            primitiveType = aod.schema.primitives.PrimitiveTypes.get(primitiveType);
            if isequal(obj.primitiveType, primitiveType)
                return
            end
            newPrimitive = aod.schema.util.createPrimitive(...
                primitiveType, obj.Name, obj);
            obj.Primitive = newPrimitive;
        end
    end

    % Methods that pass to primitive
    methods
        function assign(obj, varargin)
            obj.Primitive.assign(varargin{:});
        end

        function [tf, ME] = validate(obj, input, errorType)
            arguments
                obj
                input
                errorType           = aod.infra.ErrorTypes.ERROR
            end
            
            errorType = aod.infra.ErrorTypes.init(errorType);

            [tf, ME] = obj.Primitive.validate(input, errorType);
        end

        function [tf, ME] = checkIntegrity(obj, throwError)
            if nargin < 2
                throwError = false;
            end

            [tf, ME] = obj.Primitive.checkIntegrity(throwError);
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

        function checkPrimitiveType(obj)
            % Confirm parent collection supports requested primitive type
            %
            % Syntax:
            %   checkPrimitiveType(obj)
            % -------------------------------------------------------------
            if ~ismember(obj.primitiveType, obj.Parent.ALLOWABLE_PRIMITIVE_TYPES)
                error('checkPrimitiveType:InvalidTypeForCollection',...
                    '%s does not support primitives of type %s',...
                    getClassWithoutPackages(obj.Parent), char(obj.primitiveType));
            end
        end

        function setName(obj, name)
            % Set the primitive's name, ensuring valid variable name
            %
            % Syntax:
            %   setName(obj, name)
            %
            % See also:
            %   isvarname
            % -------------------------------------------------------------
            arguments
                obj
                name    (1,1)       string
            end

            if ~isvarname(name)
                error('setName:InvalidName',...
                    'Property names must be valid MATLAB variables');
            end
            obj.Name = name;
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