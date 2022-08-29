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
%   obj = ReflectancePower(calibrationDate);
% -------------------------------------------------------------------------

    methods
        function obj = ReflectancePower(calibrationDate)
            obj = obj@aod.builtin.calibrations.PowerMeasurement(...
                [], calibrationDate, 796, 'SettingUnit', 'None');
        end
    end
end