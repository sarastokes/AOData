classdef UnrestrictedDimension < aod.specification.Specification
% An unrestricted dimension, equivalent of ":"
%
% Parent:
%   aod.specification.Size
%
% Constructor:
%   obj = aod.specification.size.UnrestrictedDimension()
%

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    methods
        function obj = UnrestrictedDimension()
        end

        function tf = validate(~, ~)
            tf = true;
        end

        function output = text(obj)
            output = ":";
        end
    end
end