classdef PrimitiveTypes
% PRIMITIVETYPES
%
% Description:
%   Enumeration for typing primitives
%
% Static methods:
%   obj = get(input)
%   obj = find(data)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    enumeration
        BOOLEAN
        CATEGORICAL
        DATE
        DURATION
        FILE
        INTEGER
        LINK
        NUMBER
        TABLE
        TEXT
        UNKNOWN
    end

    methods
        function tf = isTableAllowedParent(obj)
            %% TODO: choose between this and allowableChild property
            txt = string(obj);
            if ismember(txt, ["BOOLEAN", "DATE", "DURATION", "NUMBER", "INTEGER", "TEXT"])
                tf = true;
            else
                tf = false;
            end
        end

        function fcn = fcnHandle(obj)
            fcn = eval(sprintf('@aod.schema.primitives.%s',...
                appbox.capitalize(string(obj))));
        end
    end

    methods (Static)
        function obj = get(input)
            import aod.schema.primitives.PrimitiveTypes

            input = convertStringsToChars(input);
            input = lower(input);

            switch input
                case 'boolean'
                    obj = PrimitiveTypes.BOOLEAN;
                case 'date'
                    obj = PrimitiveTypes.DATE;
                case 'duration'
                    obj = PrimitiveTypes.DURATION;
                case 'file'
                    obj = PrimitiveTypes.FILE;
                case {'number', 'numeric'}
                    obj = PrimitiveTypes.NUMBER;
                case 'integer'
                    obj = PrimitiveTypes.INTEGER;
                case 'link'
                    obj = PrimitiveTypes.LINK;
                case 'text'
                    obj = PrimitiveTypes.TEXT;
                case 'table'
                    obj = PrimitiveTypes.TABLE;
                case 'unknown'
                    obj = PrimitiveTypes.UNKNOWN;
                otherwise
                    error('get:InvalidInput', 'Unrecognized input: %s', input);
            end
        end

        function fcn = getFcnHandle(input)
            obj = aod.schema.primitives.PrimitiveTypes.get(input);
            fcn = obj.fcnHandle();
        end

        function obj = find(data)
            import aod.schema.primitives.PrimitiveTypes

            if isSubclass(data, 'aod.common.Entity')
                obj = PrimitiveTypes.LINK;
            elseif isinteger(data)
                obj = PrimitiveTypes.INTEGER;
            elseif isa(data, 'double')
                obj = PrimitiveTypes.NUMBER;
            elseif iscategorical(data)
                obj = PrimitiveTypes.CATEGORICAL;
            elseif isstring(data)
                obj = PrimitiveTypes.TEXT;
            elseif istable(data)
                obj = PrimitiveTypes.TABLE;
            elseif istext(data)
                if isfile(data)
                    obj = PrimitiveTypes.FILE;
                else
                    obj = PrimitiveTypes.TEXT;
                end
            elseif isenum(data) || iscategorical(data)
                error('find:NotYetImplemented', 'Enum type not yet implemented');
            end
        end
    end
end