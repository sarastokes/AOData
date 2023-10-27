classdef IndexedCollection < handle
% INDEXEDCOLLECTION
%
% Description:
%   A collection of primitives accessible by their name or index.
%
% Superclasses:
%   handle
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

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        Parent
        Primitives
    end

    properties (Dependent)
        Count
    end

    methods
        function obj = IndexedCollection(parent)
            if nargin > 0
                obj.setParent(parent);
            end
        end
    end

    methods
        function value = get.Count(obj)
            value = numel(obj.Primitives);
        end
    end

    methods

        function tf = has(obj, ID)
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

            p = obj.Primitives(ID);
        end

        function add(obj, p)
            % ADD  Adds a new primitive to the collection
            % -------------------------------------------------------------
            arguments
                obj     (1,1)   aod.schema.collections.IndexedCollection
                p               aod.schema.primitives.Primitive
            end

            obj.Primitives = [obj.Primitives; p];
        end

        function remove(obj, ID)
            % REMOVE  Removes the primitive matching name or index
            % -------------------------------------------------------------

            if ~obj.has(ID)
                error('remove:PrimitiveNotFound',...
                    'No primitive found for input %s', value2string(ID));
            end
            if istext(ID)
                ID = obj.name2id(ID);
            end

            obj.Primitives(ID) = [];
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

            obj.Primitives(ID).assign(varargin{:});
        end
    end

    methods
        function record = getRecord(obj)
            % GETRECORD  Match primitive getRecord to keep chain intact
            if isempty(obj.Parent)
                record = [];
            else
                record = obj.Parent.getRecord();
            end
        end

        function [tf, ME, excObj] = checkIntegrity(obj)
            
            excObj = aod.schema.exceptions.SchemaIntegrityException(obj);
            for i = 1:obj.Count
                [iTF, iME] = obj.Primitives(i).checkIntegrity(false);
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
            % CLEAR  Ensure Primitives is fully empty
            obj.Primitives = [];
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
                ID = find(arrayfun(@(x) strcmpi(x.Name, name), obj.Primitives));
            end
        end
    end
end