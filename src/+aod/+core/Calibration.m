classdef (Abstract) Calibration < aod.core.Entity
% CALIBRATION
%
% Constructor:
%   obj = aod.core.Calibration(parent, varargin)
%   obj = aod.core.Calibration(varargin)
%
% Abstract methods:
%   addCalibration(obj, varargin)
%   loadCalibration(obj, varargin)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        calibrationDate(1,1) datetime
    end

    methods (Abstract)
        addCalibration(obj, varargin)
        loadCalibration(obj, varargin)
    end

    methods
        function obj = Calibration(varargin)
            obj.allowableParentTypes = {'aod.core.Dataset'};

            ip = inputParser();
            ip.CaseSensitive = false;
            ip.KeepUnmatched = true;
            addOptional(ip, 'Parent', [], @(x) isa(x, 'aod.core.Entity'));
            addParameter(ip, 'CalibrationDate', [], @ischar);
            parse(ip, varargin{:});
            
            parent = ip.Results.Parent;
            calDate = ip.Results.CalibrationDate;

            obj.addParent(parent);
            obj.calibrationDate = datetime(calDate, 'Format', 'yyyyMMdd');
        end
    end
end

