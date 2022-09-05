classdef ErrorTypes 

    enumeration
        ERROR
        WARNING 
        MISSING
        NONE 
    end

    methods (Static)
        function obj = init(value)
            if isa(value, 'aod.util.ErrorTypes')
                obj = value;
                return 
            end

            import aod.util.ErrorTypes

            switch lower(value)
                case 'error'
                    obj = aod.util.ErrorTypes.ERROR;
                case 'warning'
                    obj = aod.util.ErrorTypes.WARNING;
                case 'missing'
                    obj = aod.util.ErrorTypes.MISSING;
                case 'none'
                    obj = aod.util.ErrorTypes.NONE;
                otherwise
                    error("ErrorTypes:UnrecognizedInput",...
                        'Message levels are error, warning and none');
            end
        end
    end
end