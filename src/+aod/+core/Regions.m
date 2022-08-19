classdef Regions < aod.core.Entity 
% REGIONS
%
% Constructor:
%   obj = Regions(parent, rois, varargin)
%
% Private parameters:
%   Count
%   RoiIDs
%
% Properties:
%   Map                     labeled map of region locations
%   regionParameters        aod.core.Parameters
% Dependent properties:
%   count
%   roiIDs
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        Map                 double
        regionParameters    = aod.core.Parameters
    end

    % Enables quick access to commonly-used parameters
    properties (Dependent)
        count
        roiIDs
    end

    properties (Access = protected)
        Reader
    end

    methods
        function obj = Regions(parent, rois)
            obj = obj@aod.core.Entity();
            obj.allowableParentTypes = {'aod.core.Experiment'};

            if nargin > 0
                obj.setParent(parent);
            end

            if nargin > 1 && ~isempty(rois)
                if ~ischar(rois) || ~isstring(rois)
                    obj.Map = rois;
                end
            end
        end

        function value = get.count(obj)
            if obj.regionParameters.isKey('Count')
                value = obj.regionParameters('Count');
            else 
                value = 0;
            end
        end

        function value = get.roiIDs(obj)
            if obj.regionParameters.isKey('RoiIDs')
                value = obj.regionParameters('RoiIDs');
            else 
                value = [];
            end
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
            IDs = unique(obj.Map);
            IDs(obj.roiIDs == 0) = [];
            roiCount = nnz(unique(obj.Map));

            obj.addParameter('RoiIDs', IDs);
            obj.addParameter('Count', roiCount);
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
                    obj.regionParameters(k{i}) = S.(k{i});
                end
            else
                for i = 1:(nargin - 1)/2
                    obj.regionParameters(varargin{(2*i)-1}) = varargin{2*i};
                end
            end
        end

        function value = getParameter(obj, paramName)
            if obj.regionParameters.isKey(paramName)
                value = obj.regionParameters(paramName);
            else
                value = [];
            end
        end
    end
end
