classdef Regions < aod.core.Entity 
% REGIONS
%
% Constructor:
%   obj = Regions(parent, rois, varargin)
%
% 
% Properties:
%   Map                     labeled map of region locations
%   Count                   number of regions in map
%   roiIDs                  IDs of all regions in map
%   regionParameters        aod.core.Parameters
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        Map                 double
        Count(1,1)          {mustBeInteger}  = 0
        roiIDs(1,:)         {mustBeInteger}  = 0 
        regionParameters    % aod.core.Parameters
    end

    properties (Access = protected)
        Reader
    end

    methods
        function obj = Regions(parent, rois)
            obj = obj@aod.core.Entity();
            obj.allowableParentTypes = {'aod.core.Dataset', 'aod.core.Epoch'};

            if nargin > 0
                obj.setParent(parent);
            end

            if nargin > 1 && ~isempty(rois)
                if ~ischar(rois) || ~isstring(rois)
                    obj.Map = rois;
                end
            end

            obj.regionParameters = aod.core.Parameters();
        end
    end

    methods (Sealed, Access = protected)
        function setMap(obj, roiMap)
            % SETMAP
            %
            % Description:
            %   Assigns Map property and all derived properties
            %
            % Syntax:
            %   obj.setMap(roiMap);
            % -------------------------------------------------------------
            obj.Map = roiMap;
            obj.roiIDs = unique(obj.Map);
            obj.roiIDs(obj.roiIDs == 0) = [];
            obj.Count = nnz(unique(obj.Map));
        end
    end

    methods (Sealed)
        function addParameter(obj, varargin)
            % ADDPARAMETER
            %
            % Syntax:
            %   obj.addParameter(paramName, value)
            %   obj.addParameter(paramName, value, paramName, value)
            %   obj.addParameter(struct)
            % -------------------------------------------------------------
            if nargin == 1
                return
            end
            if nargin == 2 && isstruct(varargin{1})
                S = varargin{1};
                k = fieldnames(S);
                for i = 1:numel(k)
                    obj.datasetParameters(k{i}) = S.(k{i});
                end
            else
                for i = 1:(nargin - 1)/2
                    obj.datasetParameters(varargin{(2*i)-1}) = varargin{2*i};
                end
            end
        end
    end
end
