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
%   obj = BeaconPower(parent, calibrationDate)
% -------------------------------------------------------------------------
    methods
        function obj = BeaconPower(parent, calibrationDate)
            obj = obj@aod.builtin.calibrations.PowerMeasurement(parent,...
                calibrationDate, 847, 'SettingUnit', 'mA');
        end
    end
end 