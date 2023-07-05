classdef (Abstract) Validator < aod.specification.Specification 

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    methods (Abstract)
        [tf, ME] = validate(obj, input)
    end

    methods
        function obj = Validator()
        end
    end
end 