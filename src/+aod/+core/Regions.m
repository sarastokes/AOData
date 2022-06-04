classdef (Abstract) Regions < aod.core.Entity
% REGIONS
%
% Constructor:
%   obj = Regions(parent, rois, varargin)
%
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        Map                 double
        Count(1,1)          {mustBeInteger}  = 0
    end

    properties (Access = protected)
        Reader
    end

    methods
        function obj = Regions(parent, rois, varargin)

            obj.allowableParentTypes = {'aod.core.Dataset', 'aod.core.Epoch'};

            if nargin > 0 && ~isempty(parent)
                obj.setParent(parent);
            end

            if nargin > 1 && ~isempty(rois)
                if ~ischar(rois) || ~isstring(rois)
                    obj.Map = rois;
                end
            end
        end
    end

    methods (Access = protected)
        function setMap(obj, roiMap)
            obj.Map = roiMap;
            obj.Count = nnz(unique(obj.Map));
        end
    end
end
