classdef (Abstract) Container < aod.schema.primitives.Primitive
% CONTAINER (Abstract)
%
% Superclasses:
%   aod.schema.primitives.Primitive
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
            aod.schema.primitives.PrimitiveTypes.DATE,...
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
            obj = obj@aod.schema.primitives.Primitive(name, parent);
            obj.Collection = aod.schema.collections.IndexedCollection(obj);
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
            else
                if obj.isInitializing
                    p = obj.createPrimitive(varargin{:});
                    obj.addItem(p);
                else
                    obj.editItem(varargin{:});
                end
            end
        end

        function editItem(obj, ID, varargin)
            obj.Collections.set(ID, varargin{:});
        end

        function addItem(obj, newItem)
            arguments
                obj         (1,1)   aod.schema.primitives.Container
                newItem             aod.schema.primitives.Primitive
            end

            if ~isscalar(newItem)
                arrayfun(@(x) addItem(obj, x), newItem);
                return;
            end

            if ~ismember(newItem.PRIMITIVE_TYPE, obj.ALLOWABLE_CHILD_TYPES)
                error('addItem:InvalidPrimitive',...
                    'Field %s cannot be added to %s because it has a primitive type (%s) that is not supported for containers',...
                    newItem.Name, obj.Name, string(newItem.PRIMITIVE_TYPE));
            end

            obj.Collection.add(newItem);
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
                tf = true; ME = [];
                return
            end
            
            [tf, ME, excObj] = obj.Collection.checkIntegrity();

            if ~tf && throwError
                throw(ME);
            end
        end
    end

    methods (Access = protected)
        function p = createPrimitive(obj, type, name, varargin)
            p = aod.schema.util.createPrimitive(type, name, obj, varargin{:});
        end
    end
end