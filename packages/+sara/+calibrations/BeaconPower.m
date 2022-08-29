classdef BeaconPower < aod.builtin.calibrations.PowerMeasurement
% BEACONPOWER
%
% Description:
%   Power measurements of wavefront-sensing beacon
%
% Parent:
%   aod.builtin.calibrations.PowerMeasurement
%
% Constructor:
%   obj = BeaconPower(calibrationDate)
% -------------------------------------------------------------------------
    methods
        function obj = BeaconPower(calibrationDate)
            obj = obj@aod.builtin.calibrations.PowerMeasurement(...
                [], calibrationDate, 847, 'SettingUnit', 'mA');
        end
    end
end 