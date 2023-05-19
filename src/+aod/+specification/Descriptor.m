classdef (Abstract) Descriptor < aod.specification.Specification
% (Abstract) Parent class for metadata descriptions

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    methods (Abstract, Access = protected)
        assign(obj, input)
    end
    
    methods
        function obj = Descriptor(input)
            obj.assign(input);
        end
    end
end 