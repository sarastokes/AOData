classdef Calibration < aod.core.Entity & matlab.mixin.Heterogeneous
% CALIBRATION
%
% Description:
%   A calibration associated with the system or experiment
%
% Constructor:
%   obj = aod.core.Calibration(parent, calibrationDate)
%
% Parent:
%   aod.core.Entity, matlab.mixin.Heterogeneous
%
% Properties:
%   calibrationDate         date calibration was performed (yyyyMMdd)
%   calibrationParameters   aod.core.Parameters
%
% Sealed methods:
%   setCalibrationDate(obj, calibrationDate)
%
% Inherited public methods:
%   setParam(obj, varargin)
%   value = getParam(obj, paramName, mustReturnParam)
%   tf = hasParam(obj, paramName)
%
% Note:
%   Inheriting matlab.mixin.Heterogeneous allows creation of arrays
%   containing different subclasses of aod.core.Calibration
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        calibrationDate(1,1)                datetime
        % calibrationParameters               = aod.core.Parameters
    end

    properties (Hidden, SetAccess = protected)
        allowableParentTypes = {'aod.core.Experiment'};
        % parameterPropertyName = 'calibrationParameters';
    end

    methods
        function obj = Calibration(parent, calibrationDate)
            obj = obj@aod.core.Entity(parent);
            
            if nargin > 1 && ~isempty(calibrationDate)
                obj.setCalibrationDate(calibrationDate);
            end
        end
    end

    methods (Sealed)
        function setCalibrationDate(obj, calDate)
            % SETCALIBRATIONDATE
            %
            % Description:
            %   Set the date where the calibration was performed
            % 
            % Syntax:
            %   obj.setCalibrationDate(calDate)
            %
            % Inputs:
            %   calDate             datetime, or char: 'yyyyMMdd'
            % -------------------------------------------------------------
            if ~isdatetime(calDate)
                try
                    calDate = datetime(calDate, 'Format', 'yyyyMMdd');
                catch ME 
                    if strcmp(ME.id, 'MATLAB:datestr:ConvertToDateNumber')
                        error("setCalibrationDate:FailedDatetimeConversion",...
                            "Failed to convert to datetime, use format yyyyMMdd");
                    else
                        rethrow(ME);
                    end
                end
            end
            obj.calibrationDate = calDate;
        end
    end
end

