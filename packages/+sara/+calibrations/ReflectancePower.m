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
%   obj = ReflectancePower(parent, calibrationDate);
% -------------------------------------------------------------------------

    methods
        function obj = ReflectancePower(parent, calibrationDate)
            obj = obj@aod.builtin.calibrations.PowerMeasurement(parent,...
                calibrationDate, 796, 'SettingUnit', 'None');
        end
    end
end