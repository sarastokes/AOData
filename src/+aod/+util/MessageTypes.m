classdef MessageTypes 

    enumeration
        ERROR
        WARNING 
        NONE 
    end

    methods (Static)
        function obj = init(value)
            if isa(value, 'aod.util.MessageTypes')
                obj = value;
                return 
            end

            switch lower(value)
                case 'error'
                    obj = aod.util.MessageTypes.ERROR;
                case 'warning'
                    obj = aod.util.MessageTypes.WARNING;
                case 'none'
                    obj = aod.util.MessageTypes.NONE;
                otherwise
                    error("MessageTypes:UnrecognizedInput",...
                        'Message levels are error, warning and none');
            end
        end
    end
end