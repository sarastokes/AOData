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