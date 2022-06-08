classdef ModelEye < aod.core.Source 

    methods
        function obj = ModelEye(varargin)
            obj@aod.core.Source(varargin{:});
        end
    end

    methods (Access = protected)
        function value = getLabel(obj)
            value = 'ModelEye';
        end
    end
end 