classdef Optimization < aod.core.Calibration 
% OPTIMIZATION
%
% Description:
%   Logs optimization of PMT and source position prior to an experiment
%
% Syntax:
%   obj = Optimization(name, calibrationDate, varargin)
%
% Parameters:
%   xPMT
%   yPMT
%   zPMT
%   zLightSource
%
% Methods:
%   setPMT(obj, x, y, z)
%   setLightSource(obj, z)
%   setSource(obj, source)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        Source 
    end

    methods
        function obj = Optimization(name, calibrationDate, varargin)
            obj = aod.core.Calibration(name, calibrationDate);
            
            ip = aod.util.InputParser();
            addParameter(ip, 'xPMT', [], @isnumeric);
            addParameter(ip, 'yPMT', [], @isnumeric);
            addParameter(ip, 'zPMT', [], @isnumeric);
            addParameter(ip, 'zLightSource', [], @isnumeric);
            parse(ip, varargin{:});

            obj.addParameter(ip.Results);
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
    end
end 