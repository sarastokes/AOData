classdef (Abstract) Validator < aod.schema.Specification
% Validator (abstract)
%
% Superclasses:
%   aod.schema.Specification
%
% Constructor:
%   obj = aod.schema.Validator(parent)
%
% Abstract methods:
%   [tf, ME] = validate(obj, input)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

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
            % Subclasses without "Value" property should modify
            tf = ~isempty(obj.Value);
        end
    end
end