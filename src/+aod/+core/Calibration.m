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
%   Target                  System, Channel or Device
%
% -------------------------------------------------------------------------
% Properties:
%   calibrationDate         datetime or text in format yyyyMMdd
%       Date calibration was performed (yyyyMMdd)
%   Target                  System, Channel or Device
%
% Attributes:
%   Administrator           string
%       Who performed the calibration
%
% Sealed methods:
%   setDate(obj, calibrationDate)
%
% -------------------------------------------------------------------------
% See Also:
%   aod.persistent.Calibration

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        calibrationDate   datetime  {mustBeScalarOrEmpty}
    end

    properties (SetAccess = protected)
        Target       {mustBeScalarOrEmpty}
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
                obj.setDate(calibrationDate);
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
            import aod.common.EntityTypes
            entityType = EntityTypes.get(target);
            
            switch entityType 
                case {EntityTypes.SYSTEM, EntityTypes.CHANNEL, EntityTypes.DEVICE}
                    obj.Target = target;
                otherwise
                    error("Calibration:InvalidTarget",...
                        "Calibration Target must be a System, Channel or Device");
            end
        end

        function setDate(obj, calDate)
            % Set the date where the calibration was performed
            % 
            % Syntax:
            %   obj.setDate(calDate)
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
    methods (Static)
        function value = specifyAttributes()
            value = specifyAttributes@aod.core.Entity();
            
            value.add('Administrator', "", @isstring,... 
                'Person(s) who performed the calibration');
        end

        function mngr = specifyDatasets(mngr)
            mngr = specifyDatasets@aod.core.Entity(mngr);

            mngr.set("Target",...
                "Size", "(1,1)",...
                "Function", {@mustBeScalarOrEmpty, ...
                    @(x) aod.util.mustBeEntityType(x, ["System", "Channel", "Device"])},...
                "Description", "Target of the calibration");
            mngr.set("calibrationDate",...
                "Size", "(1,1)",...
                "Description", "Date the calibration was performed");
        end
    end
end

