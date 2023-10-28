classdef UnrestrictedDimension < aod.schema.Validator
% An unrestricted dimension, equivalent of ":"
%
% Parent:
%   aod.schema.validators.Size
%
% Constructor:
%   obj = aod.schema.validators.size.UnrestrictedDimension(parent)
%

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------


    methods
        function obj = UnrestrictedDimension(parent)
            obj = obj@aod.schema.Validator(parent);
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

        function tf = isSpecified(~)
            tf = true;
        end
    end

    % MATLAB builtin methods
    methods
        function tf = isequal(obj, other)
            tf = isa(other, 'aod.schema.validators.size.UnrestrictedDimension');
        end
    end
end