classdef UnrestrictedDimension < aod.specification.Size
% An unrestricted dimension, equivalent of ":"
%
% Parent:
%   aod.specification.Size
%
% Constructor:
%   obj = aod.specification.size.UnrestrictedDimension
%

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    methods
        function obj = UnrestrictedDimension()
        end

        function tf = isValid(~, ~)
            tf = true;
        end
    end
end