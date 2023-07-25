classdef (Abstract) Descriptor < aod.specification.Specification
% (Abstract) Parent class for metadata descriptions
%
% Description:
%   Descriptors describe the data but are not used in validation
%
% See also:
%   aod.specification.Validator

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    methods
        function obj = Descriptor(parent)
            if nargin == 0
                parent = [];
            end
            obj = obj@aod.specification.Specification(parent);
        end
    end
end