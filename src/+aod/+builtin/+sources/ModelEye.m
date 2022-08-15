classdef ModelEye < aod.core.Source 

    methods
        function obj = ModelEye(parent, name)
            if nargin < 2
                name = 'ModelEye';
            end

            obj@aod.core.Source(parent, name);
        end
    end

    methods (Access = protected)
        function value = getLabel(obj)
            value = 'ModelEye';
        end
    end
end 