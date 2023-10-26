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

    properties (Abstract, SetAccess = protected)
        Collection              %aod.schema.PrimitiveCollection
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

    methods
        function obj = Container(name, parent, varargin)
            if nargin < 3
                parent = [];
            end
            obj = obj@aod.schema.primitives.Primitive(name, parent);

            obj.addItem(varargin{:});
        end
    end

    methods
        function primitive = getItem(obj, ID)
            primitive = obj.Collection.get(ID);
        end

        function setItem(obj, varargin)
            if isnumeric(varargin{1}) || istext(varargin{1})
                ID = varargin{1};
                obj.Collection.set(ID, varargin{2:end});
            elseif iscell(varargin{1})
                if nargin > 2
                    cellfun(@(x) setItem(obj, x), varargin{:});
                else
                    obj.setItem(uncell(varargin{1}));
                end
            end
        end

        function addItem(obj, newItem)
            arguments
                obj
                newItem           aod.schema.primitives.Primitive
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

            obj.Collection = [obj.Collection; newItem];
            if ~obj.Size.isSpecified
                obj.setSize(sprintf("(:,%u", obj.Count));
            else
                obj.Size.Value(2).setValue(obj.Count);
            end
        end

        function removeItem(obj, ID)
            obj.Collection.remove(ID);
            % TODO: This is table-specific
            if obj.Count == 0
                obj.Size.Value(2) = aod.schema.validators.size.UnrestrictedDimension();
            else
                obj.Size.Value(2).setValue(obj.Count);
            end
        end
    end

    methods
        function [tf, ME] = checkIntegrity(obj, throwError)
            arguments
                obj
                throwError     (1,1)   logical = false
            end

            if obj.isInitializing || isempty(obj.Collection)
                tf = true; ME = [];
                return
            end

            excObj = aod.schema.exceptions.SchemaIntegrityException(obj);
            for i = 1:obj.Count
                [iTF, iME] = obj.Collection(i).checkIntegrity(false);
                if ~iTF
                    excObj.addCause(iME);
                end
            end

            ME = excObj.getException();
            if ~tf && throwError
                throw(ME);
            end
        end
    end
end