classdef (Abstract) PowerMeasurement < aod.core.Calibration
% POWERMEASUREMENT (abstract)
%
% Parent:
%   aod.core.Calibration
%
% Constructor:
%   obj = PowerMeasurement(calibrationDate, parent);
%
% Methods:
%   T = table(obj)
%   addMeasurement(obj, setting, value)
%   setWavelength(obj, value)
%   setValueUnit(obj, value)
%   setSettingUnit(obj, value)
%
% Note:
%   Subclasses should set light source specific parameters (wavelength, 
%   settingUnit) in their constructors. If greater flexibility is needed,
%   use the setValueUnit(), setSettingUnit() and setWavelength() functions
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        wavelength 

        Setting
        Value

        settingUnit
        valueUnit = 'uW';
    end

    methods 
        function obj = PowerMeasurement(varargin)
            obj = obj@aod.core.Calibration(varargin{:});
        end

        function T = table(obj)
            % TABLE
            %
            % Description:
            %   Convert Setting and Value to a table
            %
            % Syntax:
            %   T = table(obj)
            % -------------------------------------------------------------
            if isempty(obj.Setting)
                error('PowerMeasurement: No measurements found');
            end
            T = table(obj.Setting, obj.Value,...
                'VariableNames', {'Setting', 'Power'});
        end

        function addMeasurement(obj, setting, value)
            % ADDMEASUREMENT
            %
            % Description:
            %   Add measurement(s)
            %
            % Syntax:
            %   addMeasurement(obj, setting, value)
            %
            % Example:
            %   obj.addMeasurement(20, 16.5);
            %   obj.addMeasurement("High", 270);
            %   obj.addMeasurement([1 100], [3.3 260]);
            % -------------------------------------------------------------
            if isrow(setting)
                setting = setting';
            end
            if isrow(value)
                value = value';
            end
            for i = 1:size(setting, 1)
                obj.Setting = cat(1, obj.Setting, setting);
                obj.Value = cat(1, obj.Value, value);
            end
        end

        function setWavelength(obj, wavelength)
            obj.wavelength = wavelength;
        end

        function setValueUnit(obj, newUnit)
            obj.valueUnit = newUnit;
        end

        function setSettingUnit(obj, newUnit)
            obj.settingUnit = newUnit;
        end
    end

    methods (Access = protected)
        function value = getLabel(obj)
            value = [char(getClassWithoutPackages(obj)), num2str(obj.wavelength), 'nm'];
        end
    end
end
