classdef PrimitiveTypes
% PRIMITIVETYPES
%
% Description:
%   Enumeration for typing primitives
%
% Methods:
%   tf = isContainer(obj)
%   tf = isNestable(obj)
%
% Static methods:
%   obj = get(input)
%   obj = find(data)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    enumeration
        BOOLEAN
        CATEGORICAL
        DATETIME
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
        function tf = isContainer(obj)
            import aod.schema.PrimitiveTypes

            tf = ismember(obj, [PrimitiveTypes.OBJECT, PrimitiveTypes.LIST, PrimitiveTypes.TABLE]);
        end

        function tf = isNestable(obj)
            % TODO: choose between this and allowableChild property
            txt = string(obj);
            tf = ismember(txt, ["TEXT", "BOOLEAN", "CATEGORICAL", "FILE",...
                                "DURATION", "DATETIME", "NUMBER", "INTEGER"]);
        end

        function fcn = fcnHandle(obj)
            fcn = eval(sprintf('@aod.schema.primitives.%s',...
                appbox.capitalize(string(obj))));
        end
    end

    methods (Static)
        function obj = get(input)
            import aod.schema.PrimitiveTypes

            if isa(input, 'aod.schema.PrimitiveTypes')
                obj = input;
                return
            end
            try
                obj = aod.schema.PrimitiveTypes.(upper(input));
            catch
                error('get:UnrecognizedPrimitiveType',...
                    'Unrecognized input %s', input);
            end
        end

        function out = list()
            mc = meta.class.fromName('aod.schema.PrimitiveTypes');
            names = arrayfun(@(x) string(x.Name), mc.EnumerationMemberList);
            out = arrayfun(@(x) aod.schema.PrimitiveTypes.get(x), names);
        end

        function fcn = getFcnHandle(input)
            obj = aod.schema.PrimitiveTypes.get(input);
            fcn = obj.fcnHandle();
        end

        function obj = find(data)
            import aod.schema.PrimitiveTypes

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
            elseif isdatetime(data)
                obj = PrimitiveTypes.DATE;
            elseif isduration(data)
                obj = PrimitiveTypes.DURATION;
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