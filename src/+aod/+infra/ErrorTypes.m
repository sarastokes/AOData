classdef ErrorTypes 
% Methods for specifying error handling in AOData
%
% Description:
%   Enumerated type standardizing error handling
%
% TODO: Improve or remove

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    enumeration
        ERROR
        WARNING 
        MISSING
        NONE 
    end

    methods (Static)
        function obj = init(value)
            if isa(value, 'aod.infra.ErrorTypes')
                obj = value;
                return 
            end

            import aod.infra.ErrorTypes

            switch lower(value)
                case 'error'
                    obj = aod.infra.ErrorTypes.ERROR;
                case 'warning'
                    obj = aod.infra.ErrorTypes.WARNING;
                case 'missing'
                    obj = aod.infra.ErrorTypes.MISSING;
                case 'none'
                    obj = aod.infra.ErrorTypes.NONE;
                otherwise
                    error("ErrorTypes:UnrecognizedInput",...
                        'Message levels are error, warning, missing and none');
            end
        end
    end
end