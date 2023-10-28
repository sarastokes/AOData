classdef FixedDimension < aod.schema.Validator
% A fixed dimension (must equal a specific number)
%
% Description:
%   Similar to MATLAB's meta.FixedDimension class, which isn't accessible
%   outside their metaclass interface
%
% Constructor:
%   obj = aod.schema.validators.size.FixedDimension(parent, value)
%
% Inputs:
%   parent          aod.schema.Validator.Size
%   value           double
%       The size of the dimension (must be an integer)
%
% See also:
%   meta.FixedDimension, aod.schema.validators.size.UnrestrictedDimension
%
% TODO: Should never be empty, if it is, should be UnrestrictedDimension

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Length          double      {mustBeScalarOrEmpty}     = []
    end

    methods
        function obj = FixedDimension(parent, value)
            obj = obj@aod.schema.Validator(parent);
            
            if nargin == 2 && ~obj.isInputEmpty(value)
                obj.setValue(value);
            end
        end

    end

    methods
        function setValue(obj, input)
            if obj.isInputEmpty(input)
                obj.Length = [];
                return
            end
            if istext(input)
                input = str2double(input);
            end
            mustBeInteger(input); mustBeNonnegative(input);
            obj.Length = input;
        end

        function tf = validate(obj, input)
            if obj.isInputEmpty(input)
                tf = true;
                return
            end
            if istext(input)
                input = str2double(input);
            end
            tf = (input == obj.Length);
        end

        function output = text(obj)
            output = string(num2str(obj.Length));
        end

        function tf = isSpecified(obj)
            if ~isscalar(obj)
                tf = any(arrayfun(@(x) isSpecified(x), obj));
                return
            end
            tf = ~isempty(obj.Value);
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