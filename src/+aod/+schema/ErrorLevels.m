classdef ErrorLevels < int32

    enumeration
        UNDEFINED           (0)
        ENTITY              (1)
        COLLECTION          (2)
        RECORD              (3)
        ITEM                (4)
        VALIDATOR           (5)
    end

    methods (Static)
        function out = get(input)
            if isa(input, 'aod.schema.ErrorLevels')
                out = input;
                return
            end

            if istext(input)
                try
                    out = aod.schema.ErrorLevels.(upper(input));
                    return
                catch ME
                    throwAsCaller(ME);
                end
            end

            switch class(input)
                case {'aod.core.Entity', 'aod.persistent.Entity'}
                    out = aod.schema.ErrorLevels.ENTITY;
                case 'aod.schema.Item'
                    out = aod.schema.ErrorLevels.ITEM;
                case 'aod.schema.Record'
                    out = aod.schema.ErrorLevels.RECORD;
                case 'aod.schema.Validator'
                    out = aod.schema.ErrorLevels.VALIDATOR;
                otherwise
                    out = aod.schema.ErrorLevels.UNDEFINED;
            end
        end
    end
end