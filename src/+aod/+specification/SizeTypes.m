classdef SizeTypes
% Classification of different data sizes 
%
% Static methods:
%   obj = get(input)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    enumeration
        SCALAR
        ROW 
        COLUMN 
        MATRIX
        NDARRAY
        UNDEFINED
    end

    methods
        function out = getSizing(obj)
            import aod.specification.SizeTypes

            switch obj 
                case SizeTypes.SCALAR
                    out = "(1,1)";
                case SizeTypes.ROW 
                    out = "(1,:)";
                case SizeTypes.COLUMN
                    out = "(:,1)";
                case SizeTypes.MATRIX
                    out = "(:,:)";
                case SizeTypes.UNDEFINED
                    out = [];
                case SizeTypes.NDARRAY
                    error('getSizing:NotEnoughInfo',...
                        "NDARRAY does not provide enough info to specify size");
            end
        end
    end

    methods (Static)
        function obj = get(input)

            import aod.specification.SizeTypes 

            switch lower(input)
                case 'scalar'
                    obj = SizeTypes.SCALAR;
                case 'row'
                    obj = SizeTypes.ROW;
                case 'column'
                    obj = SizeTypes.COLUMN;
                case 'matrix'
                    obj = SizeTypes.MATRIX;
                case 'ndarray'
                    obj = SizeTypes.NDARRAY;
                case 'undefined'
                    obj = SizeTypes.UNDEFINED;
                otherwise
                    error('SizeTypes:InvalidInput',...
                        'Input %s was not recognized', input);
            end 
        end
    end
end 