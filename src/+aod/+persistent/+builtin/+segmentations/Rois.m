classdef Rois < aod.core.persistent.Segmentation

    methods
        function obj = Rois(varargin)
            obj = obj@aod.core.persistent.Segmentation(varargin{:});
        end
    end
end 