classdef FixedDimension < aod.specification.Specification
% A fixed dimension (must equal a specific number)
%
% Description:
%   Similar to MATLAB's meta.FixedDimension class, which isn't accessible 
%   outside their metaclass interface
%
% Constructor:
%   obj = aod.specification.size.FixedDimension(dimSize)
%
% See also:
%   meta.FixedDimension, aod.specification.size.UnrestrictedDimension

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Length  (1,1)           {mustBeInteger, mustBeNonnegative}
    end

    methods
        function obj = FixedDimension(dimSize)
            if istext(dimSize)
                dimSize = str2double(dimSize);
            end
            obj.Length = dimSize;
        end

        function tf = validate(obj, input)
            if istext(input)
                input = str2double(input);
            end
            tf = (input == obj.Length);
        end

        function output = text(obj)
            output = string(num2str(obj.Length));
        end
    end
end