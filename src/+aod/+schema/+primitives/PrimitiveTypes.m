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
            % TODO: choose between this and allowableChild property
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

            if isa(input, 'aod.schema.primitives.PrimitiveTypes')
                obj = input;
                return
            end
            try 
                obj = aod.schema.primitives.PrimitiveTypes.(upper(input));
            catch
                error('get:UnrecognizedPrimitiveType',... 
                    'Unrecognized input %s', input);
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