classdef IndexedCollection < aod.schema.Collection
% INDEXEDCOLLECTION
%
% Description:
%   A collection of nested items accessible by name or index, depending
%   on the parent Container's primitive type.
%
% Superclasses:
%   aod.schema.Collection
%
% Constructor:
%   obj = aod.schema.collections.IndexedCollection(parent)
%
% Methods:
%   add(obj, primitive)
%   p = get(obj, ID)
%   has(obj, ID)
%   remove(obj, ID)
%   set(obj, ID, varargin)
%
% Hierarchy:
%   - Record
%       - Container
%           - IndexedCollection
%               - Primitive(s)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Parent                      % aod.schema.primitives.Container
        Items                       % aod.schema.Item
    end

    properties (Hidden, SetAccess = protected)
        SCHEMA_OBJECT_TYPE  = aod.schema.SchemaObjectTypes.ITEM_COLLECTION
    end

    properties (Dependent)
        Count   (1,1)       double          {mustBeInteger}
    end

    methods
        function obj = IndexedCollection(parent)
            if nargin > 0 && ~isempty(parent)
                obj.setParent(parent);
            end
        end
    end

    % Dependent set/get methods
    methods
        function value = get.Count(obj)
            value = numel(obj.Items);
        end
    end

    methods
        function tf = has(obj, ID)
            % HAS  Returns whether an item matching index/name is present
            if istext(ID)
                tf = ~isempty(obj.name2id(ID));
            elseif isnumeric(ID)
                mustBeInteger(ID);
                tf = arrayfun(@(x) x > 0 & x < obj.Count, ID);
            end
        end

        function p = get(obj, ID, errorType)
            % GET  Returns primitive matching name or index
            % -------------------------------------------------------------
            if nargin < 3
                errorType = aod.infra.ErrorTypes.ERROR;
            else
                errorType = aod.infra.ErrorTypes.init(errorType);
            end

            if ~obj.has(ID)
                switch errorType
                    case aod.infra.ErrorTypes.ERROR
                        error('get:PrimitiveNotFound',...
                            'Primitive matching input, %s, was not found',...
                            value2string(ID));
                    case aod.infra.ErrorTypes.WARNING
                        warning('get:PrimitiveNotFound',...
                            'Primitive matching input, %s, was not found',...
                            value2string(ID));
                end
            end

            if istext(ID)
                ID = obj.name2id(ID);
            end

            p = obj.Items(ID);
        end

        function add(obj, p)
            % ADD  Adds a new primitive to the collection
            % -------------------------------------------------------------
            arguments
                obj     (1,1)   aod.schema.collections.IndexedCollection
                p               aod.schema.Item
            end

            obj.Items = [obj.Items; p];
        end

        function remove(obj, ID)
            % REMOVE  Removes the primitive matching name or index
            % -------------------------------------------------------------

            if ~obj.has(ID)
                error('remove:ItemNotFound',...
                    'No item found for input %s', value2string(ID));
            end
            if istext(ID)
                ID = obj.name2id(ID);
            end

            obj.Items(ID) = [];
            if obj.Count == 0
                obj.clear();
            end
        end

        function set(obj, ID, varargin)
            % SET  Assigns properties to primitive matching name or index
            % -------------------------------------------------------------

            if istext(ID)
                ID = obj.name2id(ID);
            else
                mustBeInRange(ID, 1, obj.Count);
            end

            obj.Items(ID).assign(varargin{:});
        end
    end

    methods
        function names = getNames(obj)
            if obj.Count > 0
                names = arrayfun(@(x) x.Name, obj.Items);
            else
                names = [];
            end
        end

        function record = getRecord(obj)
            % GETRECORD  Match primitive getRecord to keep chain intact
            if isempty(obj.Parent)
                record = [];
            else
                record = obj.Parent.getRecord();
            end
        end
    end

    methods
        function [tf, ME, excObj] = validateItem(obj, ID, input, errorType)
            if nargin < 4
                errorType = aod.infra.ErrorTypes.NONE;
            else
                errorType = aod.infra.ErrorTypes.init(errorType);
            end

            if istext(ID)
                ID = obj.name2id(ID);
            end

            [tf, ME, excObj] = obj.Items(ID).validate(input, errorType);
        end

        function [tf, ME, excObj] = checkIntegrity(obj, ~)
            if ~isempty(obj.Parent) && obj.Parent.isInitializing
                return
            end

            % Supply Parent to exception (collection is transparent)
            excObj = aod.schema.exceptions.SchemaIntegrityException(obj.Parent);
            for i = 1:obj.Count
                [iTF, iME] = obj.Items(i).checkIntegrity(false);
                if ~iTF
                    excObj.addCause(iME);
                end
            end

            tf = ~excObj.hasErrors();
            ME = excObj.getException();
        end
    end

    methods (Access = private)
        function clear(obj)
            % CLEAR  Ensure Items is fully empty
            obj.Items = [];
        end

        function setParent(obj, parent)
            % SETPARENT  Validate input to Parent property before setting
            arguments
                obj
                parent          {mustBeSubclass(parent, 'aod.schema.primitives.Container')}
            end

            obj.Parent = parent;
        end

        function ID = name2id(obj, name)
            % NAME2ID  Convert primtive name to index in collection
            arguments
                obj
                name        string
            end

            if obj.Count == 0
                ID = [];
            else
                ID = find(arrayfun(@(x) strcmpi(x.Name, name), obj.Items));
            end
        end
    end
end