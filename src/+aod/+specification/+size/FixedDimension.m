classdef FixedDimension < aod.specification.Validator
% A fixed dimension (must equal a specific number)
%
% Description:
%   Similar to MATLAB's meta.FixedDimension class, which isn't accessible
%   outside their metaclass interface
%
% Constructor:
%   obj = aod.specification.size.FixedDimension(dimSize)
%   obj = aod.specification.size.FixedDimension(dimSize, optional)
%
% Inputs:
%   dimSize         double
%       The size of the dimension (must be an integer)
% Optional inputs:
%   optional        logical
%       Whether the dimension is optional (default: false)
%
% See also:
%   meta.FixedDimension, aod.specification.size.UnrestrictedDimension

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Length   (1,1)      double     {mustBeInteger, mustBeNonnegative}
        optional (1,1)      logical     = false
    end

    methods
        function obj = FixedDimension(dimSize, optional)
            if nargin < 2
                optional = false;
            end
            if istext(dimSize)
                dimSize = str2double(dimSize);
            end
            obj.Length = dimSize;
            obj.optional = optional;
        end

    end

    methods
        function setValue(obj, input)
            obj.Length = input;
        end

        function setOptional(obj, input)
            obj.optional = input;
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

    % MATLAB built-in methods
    methods
        function tf = isequal(obj, other)
            if isa(other, class(obj)) && obj.Length == other.Length
                tf = true;
            else
                tf = false;
            end
        end
    end
end