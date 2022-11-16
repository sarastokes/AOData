classdef Rois < aod.persistent.Segmentation

    methods
        function obj = Rois(varargin)
            obj = obj@aod.persistent.Segmentation(varargin{:});
        end
    end
end 