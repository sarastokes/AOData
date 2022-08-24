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
%
% Sealed methods:
%   setCalibrationDate(obj, calibrationDate)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        calibrationDate(1,1)                datetime
    end

    properties (Hidden, Access = protected)
        allowableParentTypes = {'aod.core.Experiment'};
    end

    methods
        function obj = Calibration(name, calibrationDate)
            obj = obj@aod.core.Entity(name);
            
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

