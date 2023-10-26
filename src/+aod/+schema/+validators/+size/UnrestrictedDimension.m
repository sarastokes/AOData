classdef UnrestrictedDimension < aod.schema.Validator
% An unrestricted dimension, equivalent of ":"
%
% Parent:
%   aod.schema.validators.Size
%
% Constructor:
%   obj = aod.schema.validators.size.UnrestrictedDimension()
%   obj = aod.schema.validators.size.UnrestrictedDimension()
%

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        optional    (1,1)       logical = false;
    end

    methods
        function obj = UnrestrictedDimension(optional)
            if nargin < 1
                optional = false;
            end
            obj.optional = optional;
        end
    end

    methods
        function setValue(~, ~)
        end

        function tf = validate(~, ~)
            tf = true;
        end

        function output = text(~)
            output = ":";
        end

        function tf = isSpecified(obj)
            tf = true;
        end
    end

    % MATLAB builtin methods
    methods
        function tf = isequal(obj, other)
            tf = isa(other, class(obj));
        end
    end
end