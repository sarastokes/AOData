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

        function fcn = getValidator(obj, value)
            import aod.specification.SizeTypes

            isFixed = isfixed(value);

            if all(isFixed)
                fcn = @(x) size(x) == horzcat(obj.Value.Length);
                return 
            end
        
            switch obj 
                case SizeTypes.SCALAR 
                    out = @(x) isscalar(x);
                case SizeTypes.ROW 
                    out = @(x) isrow(x);
                case SizeTypes.COLUMN 
                    out = @(x) iscolumn(x);
                case SizeTypes.MATRIX 
                    out = @(x) ismatrix(x);
                case SizeTypes.NDARRAY
                    out = @(x) ndims(x) == value;
                case SizeTypes.UNDEFINED 
                    out = {};
            end
            
            if any(isFixed) && ismember(obj, [SizeTypes.MATRIX, SizeTypes.NDARRAY])
                out = cat(2, out, @(x) size(x, find(isFixed)) == ... 
                    horzcat(obj.Value(isFixed)).Length);
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