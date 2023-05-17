classdef FixedDimension < aod.specification.Size
% A fixed dimension (must equal a specific number)


% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Length  (1,1)           {mustBeInteger, mustBeNonnegative}
    end

    methods
        function obj = FixedDimension(input)
            if istext(input)
                input = str2double(input);
            end
            obj.Length = input;
        end

        function tf = isValid(obj, input)
            if istext(input)
                input = str2double(input);
            end
            tf = (input == obj.Length);
        end
    end
end