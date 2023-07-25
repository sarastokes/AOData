classdef (Abstract) Validator < aod.specification.Specification 
% Validator (abstract)
%
% Superclasses:
%   aod.specification.Specification
%
% Constructor:
%   obj = aod.specification.Validator(parent)
%
% Events:
%   ValidationFailed
%
% Abstract methods:
%   [tf, ME] = validate(obj, input)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    events
        ValidationFailed
    end

    methods (Abstract)
        [tf, ME] = validate(obj, input)
    end

    methods
        function obj = Validator(parent)
            arguments 
                parent          = []
            end
            obj = obj@aod.specification.Specification(parent);
        end
    end
end 