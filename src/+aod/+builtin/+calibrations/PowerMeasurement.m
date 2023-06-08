classdef PowerMeasurement < aod.builtin.calibrations.MeasurementTable
% POWERMEASUREMENT
%
% Description:
%   Measurements of a light source's power at various settings
%
% Superclasses:
%   aod.builtin.calibrations.MeasurementTable
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
        function value = getLabel(obj)
            value = [char(getClassWithoutPackages(obj)),... 
                num2str(obj.getAttr('Wavelength')), 'nm'];
        end
    end

    methods (Static)
        function value = specifyAttributes()
            value = specifyAttributes@aod.core.Calibration();

            value.add('Wavelength', double.empty(), @isnumeric,...
                "The wavelength of the light source being measured");
        end

        function mngr = specifyDatasets(mngr)
            mngr = specifyDatasets@aod.core.Calibration(mngr);

            mngr.set('Measurements',...
                'Class', 'table');
        end
    end
end
