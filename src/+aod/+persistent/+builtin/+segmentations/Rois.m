classdef Rois < aod.persistent.Annotation
% Spatial regions of interest in acquired data (mirror)
%
% Parent:
%   aod.persistent.Annotation
%
% Constructor:
%   obj = aod.persistent.builtin.segmentations.Rois

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    methods
        function obj = Rois(varargin)
            obj = obj@aod.persistent.Annotation(varargin{:});
        end
    end
end 