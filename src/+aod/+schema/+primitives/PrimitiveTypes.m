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
        DATE
        DURATION
        INTEGER
        LINK
        NUMBER
        TEXT
        UNKNOWN
    end

    methods
        function primitive = create(obj, name, parent, varargin)
            % Going to need to create indiv functions instead of this
            primitive = aod.schema.primitives.Wrapper(name, parent,...
                'Type', lower(string(obj)), varargin{:});
        end
    end

    methods (Static)
        function obj = get(input)
            import aod.schema.primitives.PrimitiveTypes

            switch input
                case 'boolean'
                    obj = PrimitiveTypes.BOOLEAN;
                case 'date'
                    obj = PrimitiveTypes.DATE;
                case 'duration'
                    obj = PrimitiveTypes.DURATION;
                case 'number'
                    obj = PrimitiveTypes.NUMBER;
                case 'integer'
                    obj = PrimitiveTypes.INTEGER;
                case 'link'
                    obj = PrimitiveTypes.LINK;
                case 'text'
                    obj = PrimitiveTypes.TEXT;
                case 'unknown'
                    obj = PrimitiveTypes.UNKNOWN;
            end
        end

        function obj = find(data)
            import aod.schema.primitives.PrimitiveTypes

            if isSubclass(data, 'aod.common.Entity')
                obj = PrimitiveTypes.LINK;
            elseif isinteger(data)
                obj = PrimitiveTypes.INTEGER;
            elseif isa(className, 'double')
                obj = PrimitiveTypes.NUMBER;
            elseif isstring(data)
                obj = PrimitiveTypes.TEXT;
            elseif istable(data)
                error('find:NotYetImplemented', 'Table type not yet implemented');
            elseif isenum(data) || iscategorical(data)
                error('find:NotYetImplemented', 'Enum type not yet implemented');
            end
        end
    end
end