classdef (Abstract) Validator < aod.schema.Specification
% Validator (abstract)
%
% Superclasses:
%   aod.schema.Specification
%
% Constructor:
%   obj = aod.schema.Validator(parent)
%
% Events:
%   ValidationFailed
%
% Abstract methods:
%   [tf, ME] = validate(obj, input)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    events
        ValidationFailed  %% TODO: Keep events?
    end

    methods (Abstract)
        [tf, ME] = validate(obj, input)
    end

    methods
        function obj = Validator(parent)
            arguments
                parent          = []
            end
            obj = obj@aod.schema.Specification(parent);
        end
    end

    % aod.schema.Specification methods
    methods
        function tf = isSpecified(obj)
            tf = ~isempty(obj.Value);
        end
    end
end