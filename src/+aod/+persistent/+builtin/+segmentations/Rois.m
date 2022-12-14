classdef Rois < aod.persistent.Annotation

    methods
        function obj = Rois(varargin)
            obj = obj@aod.persistent.Annotation(varargin{:});
        end
    end
end 