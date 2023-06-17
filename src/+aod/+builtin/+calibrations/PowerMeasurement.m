classdef PowerMeasurement < aod.builtin.calibrations.MeasurementTable
% Power measurements of a light source
%
% Description:
%   Measurements of a light source's power at various settings
%
% Superclasses:
%   aod.builtin.calibrations.MeasurementTable
%
% Constructor:
%   obj = PowerMeasurement(name, calibrationDate, wavelength,...
%       colNames, colUnits, varargin);
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

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    methods 
        function obj = PowerMeasurement(name, calibrationDate, wavelength, colNames, units, varargin)

            if nargin < 4 || isempty(colNames)
                colNames = ["Setting", "Power"];
            end

            if nargin < 5 || isempty(units)
                units = ["%", "microwatts"];
            end
            obj = obj@aod.builtin.calibrations.MeasurementTable(name, ...
                calibrationDate, colNames, units, varargin{:});
            
            % Required input parsing
            obj.setAttr('Wavelength', wavelength);
        end
    end

    methods (Access = protected)
        function value = specifyLabel(obj)
            value = specifyLabel@aod.builtin.calibrations.MeasurementTable(obj);
            wl = obj.getAttr('Wavelength');
            if ~isempty(wl) && numel(wl) == 1
                value = value + string(num2str(wl)) + "nm";
            end
        end
    end

    methods (Static)
        function value = specifyAttributes()
            value = specifyAttributes@aod.builtin.calibrations.MeasurementTable();

            value.add('Wavelength', double.empty(), @isnumeric, ...
                "The wavelength of the light source being measured");
        end

        function value = specifyDatasets(value)
            value = specifyDatasets@aod.builtin.calibrations.MeasurementTable(value);

            value.set('Measurements', ...
                'Class', 'table');
        end
    end
end
