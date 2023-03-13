classdef ReturnTypes
% Enumeration for different return types in AOQuery
% 
% Description:
%   Enumeration containing all valid return types for AOQuery
%
% Static Methods:
%   out = aod.api.ReturnTypes.init(name)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    enumeration
        ENTITY
        PATH
        PARAMETER
        DATASET
    end

    methods (Static)
        function out = init(txt)
            
            if isa(txt, 'aod.api.ReturnTypes')
                out = txt;
                return
            end

            switch lower(txt)
                case 'entity'
                    out = ReturnTypes.ENTITY;
                case 'path'
                    out = ReturnTypes.PATH;
                case 'parameter'
                    out = ReturnTypes.PARAMETER;
                case 'dataset'
                    out = ReturnTypes.DATASET;
                otherwise
                    error("init:InvalidInput",...
                        "Unrecognized return type %s", txt);
            end
        end
    end

end