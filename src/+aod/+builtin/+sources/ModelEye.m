classdef ModelEye < aod.core.Source 

    methods
        function obj = ModelEye(varargin)
            obj@aod.core.Source(varargin{:});
        end
    end

    methods (Access = protected)
        function displayName = getDisplayName(obj)
            displayName = 'ModelEye';
        end
    end
end 