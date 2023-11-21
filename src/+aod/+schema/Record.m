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
        Parent                  % aod.schema.RecordCollection
        Primitive               % aod.schema.Primitive
    end

    properties (Dependent)
        % TODO: isNested
        Required        (1,1)   logical
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

        function value = get.Required(obj)
            value = obj.Primitive.Required;
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

        function out = getSpec(obj, specName, itemName)
            if nargin == 3
                if isSubclass(obj.Primitive, "aod.schema.primitives.Container")
                    item = obj.Primitive.getItem(itemName);
                    out = item.(specName);
                    return
                else
                    error('getSpec:ItemProvidedForNonContainer',...
                        'Cannot specify an item name (%s) for a container', itemName);
                end
            end
            out = obj.Primitive.(specName);
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

        function out = code(obj, collectionVarName)
            % CODE  Returns the code for the primitive
            %
            % Syntax:
            %   out = code(obj)
            % -------------------------------------------------------------
            arguments
                obj
                collectionVarName  (1,1)     string = "value"
            end
            if ~isempty(obj.Parent) && obj.Parent.recordType == "Dataset"
                fcnName = 'set';
            else
                fcnName = 'add';
            end
            out = sprintf('\t\t\t%s.%s("%s", "%s"', ...
                collectionVarName, fcnName, obj.Name, char(obj.primitiveType));
            for i = 1:numel(obj.Primitive.OPTIONS)
                if ~obj.Primitive.(obj.Primitive.OPTIONS(i)).isSpecified()
                    continue
                end
                out = sprintf('%s,...\n\t\t\t\t"%s", %s', out,...
                    obj.Primitive.OPTIONS(i), obj.Primitive.(obj.Primitive.OPTIONS(i)).jsonencode());
            end
            out = sprintf("%s);\n", out);
            out = string(out);

        end
    end

    % Methods that pass to primitive
    methods
        function assign(obj, varargin)
            obj.Primitive.assign(varargin{:});
        end

        function [tf, ME, excObj] = validate(obj, input, errorType)
            arguments
                obj
                input
                errorType           = aod.infra.ErrorTypes.ERROR
            end

            errorType = aod.infra.ErrorTypes.init(errorType);

            [tf, ME, excObj] = obj.Primitive.validate(input, errorType);
        end

        function [tf, ME] = checkIntegrity(obj, throwError)
            if nargin < 2
                throwError = false;
            end

            [tf, ME] = obj.Primitive.checkIntegrity(throwError);
        end

        function tf = isUndefined(obj)
            % ISUNDEFINED  Returns true if the primitive is undefined
            tf = obj.primitiveType == aod.schema.primitives.PrimitiveTypes.UNKNOWN;
        end
    end

    methods (Access = private)
        function setParent(obj, parent)
            arguments
                obj
                parent      %{mustBeSubclass(parent, ["aod.schema.RecordCollection, aod.schema.collections.IndexedCollection"])}
            end

            % TODO: Think about Container primitive parentage
            %if ~isSubclass(parent, ["aod.schema.RecordCollection", "aod.schema.collections.IndexedCollection"])
            %    error("setParent:InvalidInput", "Must be a collection subclass");
            %end
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

        function S = struct(obj)
            S = obj.Primitive.struct();
        end
    end
end