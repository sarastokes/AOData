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

    % MATLAB builtin methods
    methods
        function tf = isequal(obj, other)
            if ~isa(other, class(obj))
                tf = false;
                return
            end

            % If a subclass doesn't have Value, they should override this
            if isprop(obj, 'Value') && isprop(other, 'Value')
                tf = isequal(obj.Value, other.Value);
            end
        end
    end
end