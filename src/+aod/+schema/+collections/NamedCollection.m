classdef NamedCollection < aod.schema.collections.PrimitiveCollection
% NAMEDCOLLECTION
%
% Description:
%   A collection of primitives where each is referred to by a name rather
%   than an ID number. Useful for tables and structs
%
% Superclasses:
%   aod.schema.collections.PrimitiveCollection
%
% By Sara Patterson, 2023 (AOData)
% --------------------------------------------------------------------------

    properties (Dependent)
        Names
    end

    methods
        function obj = NamedCollection(parent)
            obj = obj@aod.schema.collections.PrimitiveCollection(parent);
        end

    end

    methods 
        function value = get.Names(obj)
            if obj.Count == 0
                value = [];
            else
                value = cat(1, obj.Primitives.Name);
            end
        end
    end

    methods
        function tf = has(obj, name)
            ID = obj.name2id(name);
            tf = has@aod.schema.collections.PrimitiveCollection(obj, ID);
        end

        function p = get(obj, name)
            ID = obj.name2id(name);
            p = get@aod.schema.collections.PrimitiveCollection(obj, ID);
        end

        function set(obj, name, varargin)
            ID = obj.name2id(name);
            set@aod.schema.collections.PrimitiveCollection(obj, ID, varargin{:});
        end

        function remove(obj, name)
            ID = obj.name2id(name);
            remove@aod.schema.collections.PrimitiveCollection(obj, ID);
        end
    end

    methods (Access = private)
        function ID = name2id(obj, name)
            arguments
                obj
                name        string
            end

            if ~isscalar(name)
                ID = arrayfun(@(x) name2id(obj, x), name);
                return
            end

            ID = find(obj.Names == name);
            if isempty(ID)
                error('name2id:NameNotFound',...
                    '"%s" was not in the collection', name);
            end
        end
    end
end