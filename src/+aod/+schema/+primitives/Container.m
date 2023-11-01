classdef (Abstract) Container < aod.schema.Primitive
% CONTAINER (Abstract)
%
% Superclasses:
%   aod.schema.Primitive
%
% Notes:
%   - Subclasses need to decide whether to create a new field or assign to
%   an existing field. Container takes indices into the Collection property
%   and if the subclass identifies fields in another way (e.g., keys), that
%   must be handled before passing to a Container function.

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        Collection          aod.schema.collections.IndexedCollection
    end

    properties (Hidden, SetAccess = protected)
        % Basically no nested data (e.g., struct inside a struct)
        ALLOWABLE_CHILD_TYPES = [...
            aod.schema.primitives.PrimitiveTypes.TEXT,...
            aod.schema.primitives.PrimitiveTypes.NUMBER,...
            aod.schema.primitives.PrimitiveTypes.INTEGER,...
            aod.schema.primitives.PrimitiveTypes.DURATION,...
            aod.schema.primitives.PrimitiveTypes.DATETIME,...
            aod.schema.primitives.PrimitiveTypes.FILE,...
            aod.schema.primitives.PrimitiveTypes.BOOLEAN];
    end

    properties (Dependent)
        numItems        (1,1)
    end

    methods
        function obj = Container(name, parent, varargin)
            if nargin < 3
                parent = [];
            end

            obj = obj@aod.schema.Primitive(name, parent);

            obj.Collection = aod.schema.collections.IndexedCollection(obj);
            obj.isContainer = true;
        end
    end

    % Dependent set/get methods
    methods
        function value = get.numItems(obj)
            value = obj.Collection.Count;
        end
    end

    methods
        function primitive = getItem(obj, ID)
            primitive = obj.Collection.get(ID);
        end

        function setItems(obj, varargin)
            if isempty(varargin{1})
                return
            end
            if iscell(varargin{1})
                for i = 1:numel(varargin)
                    setItems(obj, varargin{i}{:});
                end
            elseif isstruct(varargin{1})
                if obj.numItems ~= 0
                    error("setItems:InvalidInput", "User-provided input must be cell");
                end
                obj.Collection = aod.h5.readSchemaCollection(varargin{1}, obj, true);
            else
                if obj.isInitializing
                    p = obj.createPrimitive(varargin{:});
                    obj.doAddItem(p);
                else
                    obj.editItem(varargin{:});
                end
            end
        end

        function addItem(obj, varargin)
            if isa(varargin{1}, 'aod.schema.Primitive')
                obj.doAddItem(p);
            elseif iscell(varargin{1})
                for i = 1:numel(varargin)
                    obj.addItem(varargin{i}{:});
                end
            else % TODO: Error catching
                p = obj.createPrimitive(varargin{:});
                obj.doAddItem(p);
            end
        end

        function editItem(obj, ID, varargin)
            obj.Collection.set(ID, varargin{:});
        end

        function removeItem(obj, ID)
            obj.Collection.remove(ID);
        end
    end

    methods
        function [tf, ME, excObj] = checkIntegrity(obj, throwError)
            arguments
                obj
                throwError     (1,1)   logical = false
            end

            if obj.isInitializing || isempty(obj.Collection)
                return
            end

            [tf, ME, excObj] = obj.Collection.checkIntegrity();

            if ~tf && throwError
                throw(ME);
            end
        end

        function [tf, ME, excObj] = validate(obj, input, errorType)
            arguments
                obj
                input
                errorType               = aod.infra.ErrorTypes.ERROR
            end

            errorType = aod.infra.ErrorTypes.init(errorType);

            [tf, ME, excObj] = validate@aod.schema.primitives.Primitive(obj, input, errorType);

            for i = 1:obj.numItems
                [~, ~, iExc] = obj.Collection.validateItem(obj.getItemFromInput(input, i), errorType);
                excObj.addCause(iExc);
            end
        end
    end

    methods (Access = protected)
        function p = createPrimitive(obj, type, name, varargin)
            p = aod.schema.util.createPrimitive(type, name, obj, varargin{:});
        end

        function doAddItem(obj, newItem)
            arguments
                obj         (1,1)   aod.schema.primitives.Container
                newItem             aod.schema.Primitive
            end

            if ~isscalar(newItem)
                arrayfun(@(x) doAddItem(obj, x), newItem);
                return;
            end

            if ~ismember(newItem.PRIMITIVE_TYPE, obj.ALLOWABLE_CHILD_TYPES)
                error('addItem:InvalidPrimitive',...
                    'Field %s cannot be added to %s because it has a primitive type (%s) that is not supported for containers',...
                    newItem.Name, obj.Name, string(newItem.PRIMITIVE_TYPE));
            end

            obj.Collection.add(newItem);
        end
    end

    methods (Static)
        function inputItem = getItemFromInput(input, ID)
            if iscell(input)
                if isnumeric(ID)
                    inputItem = input{ID};
                else
                    error('getItemFromInput:InvalidInput',...
                        'Input must be a numeric index if input is a cell, not %s', class(ID));
                end
            elseif isstruct(input)
                if istext(ID)
                    inputItem = input.(ID);
                else
                    error('getItemFromInput:InvalidInput',...
                        'If input is a struct, ID must be a string/char fieldname not %s', class(ID));
                end
            elseif istable(input)
                inputItem = input{:, ID};
            else
                warning('getItemFromInput:InvalidInput',...
                    'Validation could not extract items from inputs of type %s', class(input));
            end
        end
    end

    % MATLAB builtin methods
    methods
        function S = struct(obj)
            S = struct@aod.schema.Primitive(obj);
            S.(obj.Name).Items = struct();
            for i = 1:obj.numItems
                S.(obj.Name).Items = catstruct(S.(obj.Name).Items, ...
                    obj.Collection.Primitives(i).struct());
            end
        end
    end
end