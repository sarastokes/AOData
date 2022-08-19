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
%
% Protected methods:
%   setMap(obj, roiMap)
%
% Inherited public methods:
%   setParam(obj, varargin)
%   value = getParam(obj, paramName, mustReturnParam)
%   tf = hasParam(obj, paramName)
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

    properties (Hidden, SetAccess = protected)
        allowableParentTypes = {'aod.core.Experiment'};
        parameterPropertyName = 'regionParameters';
    end

    methods
        function obj = Regions(parent, rois)
            obj = obj@aod.core.Entity();
            obj.setParent(parent);

            if nargin > 1 && ~isempty(rois)
                if ~ischar(rois) || ~isstring(rois)
                    obj.Map = rois;
                end
            end
        end

        function value = get.count(obj)
            value = obj.getParam('Count', aod.util.MessageTypes.NONE);
        end

        function value = get.roiIDs(obj)
            value = obj.getParam('RoiIDs', aod.util.MessageTypes.NONE);
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

            obj.setParam('RoiIDs', IDs);
            obj.setParam('Count', roiCount);
        end
    end
end
