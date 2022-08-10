classdef ReflectancePower < aod.builtin.calibrations.PowerMeasurement
% REFLECTANCEPOWER
%
% Description:
%   Power measurements of reflectance source
%
% Parent:
%   aod.builtin.calibrations.PowerMeasurement
%
% Constructor:
%   obj = ReflectancePower(calibrationDate, parent);
% -------------------------------------------------------------------------

    methods
        function obj = ReflectancePower(varargin)
            obj = obj@aod.builtin.calibrations.PowerMeasurement(varargin{:});

            obj.wavelength = 796;
            obj.settingUnit = "None";
        end
    end
end