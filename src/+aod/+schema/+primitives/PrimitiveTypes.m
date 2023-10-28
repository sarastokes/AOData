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
        LIST
        OBJECT
        TABLE
        TEXT
        UNKNOWN
    end

    methods
        function tf = isContainerAllowable(obj)
            % TODO: choose between this and allowableChild property
            txt = string(obj);
            if ismember(txt, ["BOOLEAN", "CATEGORICAL", "DATE", "DURATION", "FILE", "NUMBER", "INTEGER", "TEXT"])
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

        function out = list()
            mc = meta.class.fromName('aod.schema.primitives.PrimitiveTypes');
            names = arrayfun(@(x) string(x.Name), mc.EnumerationMemberList);
            out = arrayfun(@(x) aod.schema.primitives.PrimitiveTypes.get(x), names);
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
            elseif iscell(data)
                obj = PrimitiveTypes.LIST;
            elseif istable(data)
                obj = PrimitiveTypes.TABLE;
            elseif isstruct(data) || isa(data, 'containers.Map')
                obj = PrimitiveTypes.OBJECT;
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