classdef Optimization < aod.core.Calibration 
% OPTIMIZATION
%
% Description:
%   Logs optimization of PMT and source position prior to an experiment
%   and optionally adds adjustments made during the experiment
%
% Syntax:
%   obj = Optimization(name, calibrationDate, varargin)
%
% Parameters:
%   xPMT
%   yPMT
%   zPMT
%   zLightSource
%   xPMT_InVivo
%   yPMT_InVivo
%   zPMT_InVivo
%   zLightSource
%
% Methods:
%   setPMT(obj, x, y, z)
%   setLightSource(obj, z)
%   setSource(obj, z)
%   setLightSource_InVivo(obj, z)
%   setSource_InVivo(obj, z)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        Source 
    end

    methods
        function obj = Optimization(name, calibrationDate, varargin)
            obj = obj@aod.core.Calibration(name, calibrationDate);
            
            ip = aod.util.InputParser();
            addParameter(ip, 'xPMT', [], @isnumeric);
            addParameter(ip, 'yPMT', [], @isnumeric);
            addParameter(ip, 'zPMT', [], @isnumeric);
            addParameter(ip, 'zLightSource', [], @isnumeric);
            parse(ip, varargin{:});

            obj.setParam(ip.Results);
        end

        function setPMT(obj, x, y, z)
            if ~isempty(x)
                obj.setParam('xPMT', x);
            end
            if nargin > 2 && ~isempty(y)
                obj.setParam('yPMT', y);
            end
            if nargin > 3 && ~isempty(z)
                obj.setParam('zPMT', z);
            end
        end

        function setLightSource(obj, z)
            if ~isempty(z)
                obj.setParam('zLightSource', z);
            end
        end

        function setPMT_InVivo(obj, x, y, z)
            if ~isempty(x)
                obj.setParam('xPMT_InVivo', x);
            end
            if nargin > 2 && ~isempty(y)
                obj.setParam('yPMT_InVivo', y);
            end
            if nargin > 3 && ~isempty(z)
                obj.setParam('zPMT_InVivo', z);
            end
        end

        function setLightSource_InVivo(obj, z)
            if ~isempty(z)
                obj.setParam('zLightSource_InVivo', z);
            end
        end
    end

    methods (Access = protected)
        function value = getLabel(obj)
            value = getLabel@aod.core.Calibration(obj);
            if ~isempty(obj.Name)
                value = [obj.Name, 'Optimization'];
            end
        end
    end
end 