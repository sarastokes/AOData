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
        Collection          aod.schema.collections.ItemCollection
    end

    properties (Hidden, SetAccess = protected)
        % Basically no nested data (e.g., struct inside a struct)
        ALLOWABLE_CHILD_TYPES = [...
            aod.schema.PrimitiveTypes.TEXT,...
            aod.schema.PrimitiveTypes.NUMBER,...
            aod.schema.PrimitiveTypes.INTEGER,...
            aod.schema.PrimitiveTypes.DURATION,...
            aod.schema.PrimitiveTypes.DATETIME,...
            aod.schema.PrimitiveTypes.FILE,...
            aod.schema.PrimitiveTypes.BOOLEAN];
    end

    properties (Dependent)
        numItems        (1,1)
    end

    methods
        function obj = Container(parent, varargin)
            if nargin < 3
                parent = [];
            end

            obj = obj@aod.schema.Primitive(parent);

            obj.Collection = aod.schema.collections.ItemCollection(obj);
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
                % This is how persisted schema are repopulated:
                if obj.numItems ~= 0
                    error("setItems:InvalidInput", "User-provided input must be cell");
                end
                obj.Collection = aod.h5.readSchemaCollection(varargin{1}, obj, true);
            else
                newItem = obj.createItem(varargin{:});
                if obj.isInitializing || obj.numItems == 0 || ~obj.Collection.has(newItem.Name)
                    obj.doAddItem(newItem);
                    %p = obj.createPrimitive(varargin{:});
                    %obj.doAddItem(p);
                else
                    obj.editItem(varargin{:});
                end
            end
        end

        function addItem(obj, varargin)
            if isa(varargin{1}, 'aod.schema.Primitive')
                obj.doAddItem(varargin{1});
                if nargin > 2
                    obj.addItem(varargin{2:end}{:});
                end
            elseif iscell(varargin{1})
                for i = 1:numel(varargin)
                    obj.addItem(varargin{i}{:});
                end
            else % TODO: Error catching
                %p = obj.createPrimitive(varargin{:});
                %obj.doAddItem(p);
                newItem = aod.schema.Item(obj, varargin{:});
                obj.doAddItem(newItem);
            end
        end

        function editItem(obj, ID, varargin)
            % EDITITEM  Edit an item by name or index
            obj.Collection.set(ID, varargin{:});
        end

        function removeItem(obj, ID)
            % REMOVE  Remove an item by name or index
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

            [tf, ME, excObj] = validate@aod.schema.Primitive(obj, input, errorType);

            for i = 1:obj.numItems
                [~, ~, iExc] = obj.Collection.validateItem(obj.getItemFromInput(input, i), errorType);
                excObj.addCause(iExc);
            end
        end
    end

    methods (Access = protected)
        function newItem = createItem(obj, name, type, varargin)
            newItem = aod.schema.Item(obj, name, type, varargin{:});
        end

        function p = createPrimitive(obj, type, varargin)
            p = aod.schema.util.createPrimitive(obj, type, varargin{:});
        end

        function doAddItem(obj, newItem)
            arguments
                obj         (1,1)   aod.schema.Container
                newItem             aod.schema.Item
            end

            if ~isscalar(newItem)
                arrayfun(@(x) doAddItem(obj, x), newItem);
                return;
            end

            %if ~ismember(newItem.PRIMITIVE_TYPE, obj.ALLOWABLE_CHILD_TYPES)
            %    error('addItem:InvalidPrimitive',...
            %        'Field %s cannot be added to %s because it has a primitive type (%s) that is not supported for containers',...
            %        newItem.Name, string(obj.PRIMITIVE_TYPE), string(newItem.PRIMITIVE_TYPE));
            %end

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
                        'If input is a struct, ID must be a text fieldname not %s', class(ID));
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
            S.Items = struct();
            for i = 1:obj.numItems
                S.Items = catstruct(S.Items, ...
                    obj.Collection.Primitives(i).struct());
            end
        end
    end
end