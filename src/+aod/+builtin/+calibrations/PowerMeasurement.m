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
% Attributes:
%   settingUnit             string
%       Device setting unit (default = "normalized")
%   valueUnit               string
%       Measurement unit (default = "microwatt")
%
% Methods:
%   T = table(obj)
%   addMeasurement(obj, setting, value)
%   loadTable(obj, measurementTable)
%
% Note:
%   Subclasses should set light source specific attributes (wavelength, 
%   settingUnit) in their constructors. If greater flexibility is needed,
%   use the setValueUnit(), setSettingUnit() and setWavelength() functions

% By Sara Patterson, 2022 (AOData)
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
            
            % Required input parsing
            obj.setAttr('Wavelength', wavelength);
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
            T.Properties.VariableUnits = [obj.getAttr('SettingUnit'), obj.getAttr('ValueUnit')];
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
            
            if istext(measurementTable)
                T = readmatrix(measurementTable);
                obj.setFile('Calibration', measurementTable);
            elseif istable(measurementTable)
                obj.Setting = measurementTable.Setting;
                obj.Value = measurementTable.Value;
            end
        end
    end

    methods (Access = protected)
        function value = getLabel(obj)
            value = [char(getClassWithoutPackages(obj)),... 
                num2str(obj.getAttr('Wavelength')), 'nm'];
        end

        function value = specifyAttributes(obj)
            value = specifyAttributes@aod.core.Calibration(obj);

            value.add('Wavelength', double.empty(), @isnumeric,...
                "The wavelength of the light source being measured");
            value.add('ValueUnit', "normalized", @isstring,...
                "The units for the dependent variables");
            value.add('SettingUnit', "microwatt", @isstring,...
                "The units for the independent (measured) variables");
        end
    end
end
