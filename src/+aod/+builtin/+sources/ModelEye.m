classdef ModelEye < aod.core.Source 

    methods
        function obj = ModelEye(name)
            if nargin < 1
                name = 'ModelEye';
            end

            obj@aod.core.Source(name);
        end
    end

    methods (Access = protected)
        function value = getLabel(obj)
            value = 'ModelEye';
        end
    end
end 