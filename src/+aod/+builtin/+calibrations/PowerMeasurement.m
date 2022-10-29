classdef PowerMeasurement < aod.core.Calibration
% POWERMEASUREMENT
%
% Description:
%   Measurements of a light source's power at various settings
%
% Parent:
%   aod.core.Calibration
%
% Constructor:
%   obj = PowerMeasurement(name, calibrationDate, wavelength, varargin);
%
% Parameters:
%   settingUnit             char, device setting unit (no default)
%   valueUnit               char, measurement unit (default = 'uW')
%
% Methods:
%   T = table(obj)
%   addMeasurement(obj, setting, value)
%   loadTable(obj, measurementTable)
%
% Note:
%   Subclasses should set light source specific parameters (wavelength, 
%   settingUnit) in their constructors. If greater flexibility is needed,
%   use the setValueUnit(), setSettingUnit() and setWavelength() functions
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        measurements
    end

    properties (Access = private)
        Setting
        Value
    end

    methods 
        function obj = PowerMeasurement(name, calibrationDate, wavelength, varargin)
            obj = obj@aod.core.Calibration(name, calibrationDate);
            if numel(wavelength) > 1 && iscol(wavelength)
                wavelength = wavelength';
            end
            obj.setParam('Wavelength', wavelength);

            ip = inputParser();
            ip.KeepUnmatched = true;
            ip.CaseSensitive = false;
            addParameter(ip, 'SettingUnit', '', @ischar);
            addParameter(ip, 'ValueUnit', 'uW', @ischar);
            parse(ip, varargin{:});

            obj.setParam(ip.Results);
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
                obj.Setting = cat(1, obj.Setting, setting(i));
                obj.Value = cat(1, obj.Value, value(i));
            end
            obj.measurements = obj.table();
        end

        function loadTable(obj, measurementTable)
            % LOADTABLE 
            %
            % Description:
            %   loadTable(obj, measurementTable)
            % -------------------------------------------------------------
            assert(istable(measurementTable), 'Must be a table!');
            obj.Setting = measurementTable.Setting;
            obj.Value = measurementTable.Value;
        end
    end

    methods (Access = protected)
        function value = getLabel(obj)
            value = [char(getClassWithoutPackages(obj)),... 
                num2str(obj.getParam('Wavelength')), 'nm'];
        end
    end
end
