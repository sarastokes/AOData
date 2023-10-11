classdef (Abstract) Decorator < aod.specification.Specification
% (Abstract) Parent class for metadata decorators
%
% Description:
%   Decorators describe the data but are not used in validation
%
% See also:
%   aod.specification.Specification

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    methods
        function obj = Decorator(parent)
            if nargin == 0
                parent = [];
            end
            obj = obj@aod.specification.Specification(parent);
        end
    end
end