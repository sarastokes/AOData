classdef BeaconPower < aod.builtin.calibrations.PowerMeasurement
% BEACONPOWER
%
% Description:
%   Power measurements of wavefront-sensing beacon
%
% Parent:
%   aod.builtin.calibration.PowerMeasurement
%
% Constructor:
%   obj = BeaconPower(calibrationDate, parent)
% -------------------------------------------------------------------------
    methods
        function obj = BeaconPower(varargin)
            obj = obj@aod.builtin.calibrations.PowerMeasurement(varargin{:});

            obj.wavelength = 847;
            obj.settingUnit = 'mA';
        end
    end
end 