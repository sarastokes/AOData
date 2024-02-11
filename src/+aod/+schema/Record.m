classdef Record < aod.schema.AODataSchemaObject
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
% TODO: Name property is currently duplicated in Record and child Primitive
%
% Methods:
%   assign(obj, varargin)
%   specification = getSpec(obj, specName)
%   setPrimitive(obj, primitiveType)

% By Sara Patterson, 2023 (AOData)
% --------------------------------------------------------------------------

    properties (SetAccess = protected)
        Name            (1,1)   string
        Parent                  % aod.schema.collections.RecordCollection
    end

    properties (Hidden, SetAccess = private)
        Primitive               % aod.schema.Primitive
    end

    properties (Hidden, SetAccess = protected)
        SCHEMA_OBJECT_TYPE             = aod.schema.SchemaObjectTypes.RECORD
    end

    properties (Dependent)
        Items
        isNested        (1,1)   logical
        Required        (1,1)   logical
        className       (1,1)   string
        primitiveType   (1,1)   aod.schema.PrimitiveTypes
    end

    methods
        function obj = Record(parent, name, type, varargin)
            if isobject(parent) || ~isempty(parent)
                obj.setParent(parent);  % empty parent support for testing
            end
            obj.setName(name);

            % Create the primitive and confirm that it is valid
            obj.Primitive = aod.schema.util.createPrimitive(...
                obj, type, varargin{:});
            if isobject(parent)
                obj.checkPrimitiveType();
            end
        end
    end

    % Dependent set/get methods
    methods
        function value = get.isNested(obj)
            value = obj.Primitive.isNested;
        end

        function value = get.Items(obj)
            if obj.isNested
                value = obj.Primitive.Collection;
            else
                value = [];
            end
        end

        function value = get.Required(obj)
            value = obj.Primitive.Required;
        end

        function value = get.primitiveType(obj)
            value = obj.Primitive.PRIMITIVE_TYPE;
        end

        function value = get.className(obj)
            if isobject(obj.Parent)
                value = obj.Parent.className;
            else
                value = "";
            end
        end
    end

    methods
        function out = getSpec(obj, specName, itemName)
            % GETSPEC  Returns a specification by name
            if nargin == 3
                if isSubclass(obj.Primitive, "aod.schema.Container")
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
        function setPrimitive(obj, primitiveType)
            % SETPRIMITIVE  Assigns a primitive type to an entry
            %
            % Notes:
            %   Anything specified by the existing primitive is lost
            % -------------------------------------------------------------
            primitiveType = aod.schema.PrimitiveTypes.get(primitiveType);
            if isequal(obj.primitiveType, primitiveType)
                return
            end
            newPrimitive = aod.schema.util.createPrimitive(obj, primitiveType);
            obj.Primitive = newPrimitive;
        end
    end

    % Methods that pass to primitive
    methods
        function assign(obj, varargin)
            % ASSIGN  Assign values to specifications by name
            %
            % Syntax:
            %   assign(obj, varargin)
            % ----------------------------------------------------------
            obj.Primitive.assign(varargin{:});
        end

        function [tf, ME, excObj] = validate(obj, input, errorType)
            % VALIDATE
            %
            % Syntax:
            %   [tf, ME, excObj] = validate(obj, input)
            %   [tf, ME, excObj] = validate(obj, input, errorType)
            % ----------------------------------------------------------
            arguments
                obj
                input
                errorType           = aod.infra.ErrorTypes.ERROR
            end

            errorType = aod.infra.ErrorTypes.init(errorType);

            [tf, ME, excObj] = obj.Primitive.validate(input, errorType);
        end

        function [tf, ME] = checkIntegrity(obj, throwError)
            % CHECKINTEGRITY
            %
            % Syntax:
            %   [tf, ME] = checkIntegrity(obj, throwError)
            % ----------------------------------------------------------
            if nargin < 2
                throwError = false;
            end

            [tf, ME] = obj.Primitive.checkIntegrity(throwError);
        end

        function tf = isUndefined(obj)
            % ISUNDEFINED  Returns true if the primitive is undefined
            %
            % TODO: What about Item primitives?
            % -------------------------------------------------------------
            tf = obj.primitiveType == aod.schema.PrimitiveTypes.UNKNOWN;
        end
    end

    methods (Access = protected)
        function setParent(obj, parent)
            arguments
                obj
                parent
            end

            % TODO: Think about Container primitive parents then add
            % type-checking for Parent property.
            obj.Parent = parent;
        end

        function primitiveTypes = getAllowablePrimitiveTypes(obj)
            if isempty(obj.Parent)
                primitiveTypes = [];
                return
            end

            primitiveTypes = obj.Parent.ALLOWABLE_PRIMITIVE_TYPES;
        end
    end

    methods (Access = private)
        function checkPrimitiveType(obj)
            % Confirm parent collection supports requested primitive type
            %
            % Syntax:
            %   checkPrimitiveType(obj)
            % -------------------------------------------------------------
            allowablePrimitiveTypes = obj.getAllowablePrimitiveTypes();
            if isempty(allowablePrimitiveTypes)
                return  % Should only occur in testing
            end

            if ~ismember(obj.primitiveType, allowablePrimitiveTypes)
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

    methods (Hidden)
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

    % MATLAB builtin functions
    methods
        function tf = isequal(obj, other)
            if ~isa(other, class(obj))
                tf = false;
            else
                tf = isequal(obj.Primitive, other.Primitive);
            end
        end

        function S = struct(obj)
            pS = obj.Primitive.struct();
            S = struct();
            S.(obj.Name) = pS;
        end
    end
end