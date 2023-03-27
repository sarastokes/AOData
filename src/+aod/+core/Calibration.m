classdef Calibration < aod.core.Entity & matlab.mixin.Heterogeneous
% A measurement associated with the system or experiment
%
% Description:
%   A calibration associated with the system or experiment
%
% Parent:
%   aod.core.Entity, matlab.mixin.Heterogeneous
%
% -------------------------------------------------------------------------
%
% Constructor:
%   obj = aod.core.Calibration(name)
%   obj = aod.core.Calibration(name, 'Date', calibrationDate,...
%       'Administrator', 'AdministratorName')
%
% Inputs:
%   name                    char/string
%       Calibration name
%   calibrationDate         datetime or text in format: yyyyMMdd
%       Date the calibration was performed
% Optional key/value inputs:
%   Administrator           char/string
%       Who performed the calibration
%
% -------------------------------------------------------------------------
% Properties:
%   calibrationDate         datetime or text in format yyyyMMdd
%       Date calibration was performed (yyyyMMdd)
%
% Parameters:
%   Administrator           string
%       Who performed the calibration
%
% Sealed methods:
%   setCalibrationDate(obj, calibrationDate)
%
% -------------------------------------------------------------------------
% See Also:
%   aod.persistent.Calibration

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        calibrationDate                 datetime
    end

    properties (SetAccess = protected)
        Target       % System, Channel or Device calibrated
    end

    methods
        function obj = Calibration(name, calibrationDate, varargin)
            % CALIBRATION
            %
            % Description:
            %   A measurement associated a system or experiment
            %
            % Constructor:
            %   obj = aod.core.Calibration(name, calibrationDate)
            %   obj = aod.core.Calibration(name, calibrationDate,...
            %       'Administrator', "AdministratorName")
            %
            % Inputs:
            %   name                    char/string
            %       Calibration name
            %   calibrationDate         datetime or text (format yyyyMMdd)
            %       Date the calibration was performed
            % Optional key/value inputs:
            %   Administrator           char/string
            %       Who performed the calibration
            % -------------------------------------------------------------
            obj = obj@aod.core.Entity(name, varargin{:});
            
            if nargin > 1 && ~isempty(calibrationDate)
                obj.setCalibrationDate(calibrationDate);
            end
        end
    end 

    methods (Sealed)
        function setTarget(obj, target)
            % SETTARGET
            %
            % Description:
            %   Set the system, channel or device being calibrated
            %
            % Syntax:
            %   setTarget(obj, target)
            % -------------------------------------------------------------
            import aod.core.EntityTypes
            entityType = EntityTypes.get(target);
            
            switch entityType 
                case {EntityTypes.SYSTEM, EntityTypes.CHANNEL, EntityTypes.DEVICE}
                    obj.Target = target;
                otherwise
                    error("Calibration:InvalidTarget",...
                        "Calibration Target must be a System, Channel or Device");
            end
        end

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
            if nargin < 2 || isempty(calDate)
                obj.calibrationDate = datetime.empty();
                return
            end
            calDate = aod.util.validateDate(calDate);
            obj.calibrationDate = calDate;
        end
    end

    % aod.core.Entity methods
    methods (Access = protected)
        function value = specifyParameters(obj)
            value = specifyParameters@aod.core.Entity(obj);
            
            value.add('Administrator', [], @isstring,... 
                'Person(s) who performed the calibration');
        end
    end
end

