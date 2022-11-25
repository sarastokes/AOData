classdef ReturnTypes
% RETURNTYPES
% 
% Description:
%   Enumeration containing all valid return types for AOQuery
%
% Methods:
%   out = ReturnTypes.init(name)
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
                    error("ReturnTypes_init:UnrecognizedReturnType",...
                        "Unrecognized return type %s", txt);
            end
        end
    end

end