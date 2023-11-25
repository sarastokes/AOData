classdef SchemaObjectTypes

    enumeration
        SCHEMA
        SCHEMA_COLLECTION
        ENTITY
        RECORD_COLLECTION
        RECORD
        ITEM_COLLECTION
        ITEM
        PRIMITIVE
        CONTAINER
        DECORATOR
        DEFAULT
        VALIDATOR
    end

    methods
        function className = getClassName(obj)

            switch obj
                case SchemaObjectTypes.SCHEMA_COLLECTION
                    className = "aod.schema.collections.SchemaCollection";
                case SchemaObjectTypes.RECORD_COLLECTION
                    className = "aod.schema.collections.RecordCollection";
                case SchemaObjectTypes.ITEM_COLLECTION
                    className = "aod.schema.collections.IndexedCollection";
                case SchemaObjectTypes.CONTAINER
                    className = "aod.schema.primitives.Container";
                case SchemaObjectTypes.ENTITY
                    className = "aod.common.mixins.Entity";
                otherwise
                    className = "aod.schema." + string(obj);
            end
        end
    end


    % Builtin MATLAB methods
    methods
        function out = char(obj)
            % Returns char of entity type with correct capitalization
            %
            % Note:
            %   Necessary to avoid calling "string" bc infinite recursion
            % ----------------------------------------------------------
            import aod.schema.SchemaObjectTypes

            if ~isscalar(obj)
                out = aod.util.arrayfun(@(x) char(x), obj);
                return
            end

            switch obj
                case SchemaObjectTypes.ENTITY
                    out = 'Entity';
                case SchemaObjectTypes.SCHEMA
                    out = 'Schema';
                case SchemaObjectTypes.SCHEMA_COLLECTION
                    out = 'SchemaCollection';
                case SchemaObjectTypes.RECORD_COLLECTION
                    out = 'RecordCollection';
                case SchemaObjectTypes.ITEM_COLLECTION
                    out = 'IndexedCollection';
                case SchemaObjectTypes.RECORD
                    out = 'Record';
                case SchemaObjectTypes.ITEM
                    out = 'Item';
                case SchemaObjectTypes.PRIMITIVE
                    out = 'Primitive';
                case SchemaObjectTypes.CONTAINER
                    out = 'Container';
                case SchemaObjectTypes.VALIDATOR
                    out = 'Validator';
                case SchemaObjectTypes.DECORATOR
                    out = 'Decorator';
                case SchemaObjectTypes.DEFAULT
                    out = 'Default';
            end
        end

        function out = string(obj)
            % Returns string of entity type with correct capitalization
            %
            % Note:
            %   Necessary to avoid calling "string" bc infinite recursion
            % -------------------------------------------------------------

            if ~isscalar(obj)
                out = aod.util.arrayfun(@(x) string(x), obj);
                return
            end

            out = sprintf("%s", char(obj));
        end
    end

    methods (Static)
        function obj = get(input)
            if isa(input, 'aod.schema.SchemaObjectTypes')
                obj = input;
                return
            end

            input = convertCharsToStrings(input);
            input = lower(input);

            em = enumeration('aod.schema.SchemaObjectTypes');
            enumNames = arrayfun(@(x) lower(string(x)), em);
            idx = find(enumNames == lower(input));

            if isempty(idx)
                error('get:InvalidInput',...
                    '%s is not a recognized member of SchemaObjectTypes', input);
            end
            obj = em(idx);
        end
    end
end