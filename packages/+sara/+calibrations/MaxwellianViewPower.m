classdef MaxwellianViewPower < aod.builtin.calibrations.PowerMeasurement
% MAXWELLIANVIEWPOWER
%
% Description:
%   Power measurements for Maxwellian View which can have 1-3 LEDs
%
% Parent:
%   aod.builtin.calibrations.PowerMeasurement
%
% Syntax:
%   obj = MaxwellianViewPower(calibrationDate, whichLEDs)
%
% Example:
%   obj = MaxwellianViewPower('20220823', [420, 530, 660]);
% -------------------------------------------------------------------------

    methods
        function obj = MaxwellianViewPower(calibrationDate, whichLEDs)
            obj = obj@aod.builtin.calibrations.PowerMeasurement(...
                [], calibrationDate, whichLEDs, 'SettingUnit', 'V');
        end
    end

    methods (Access = protected)
        function value = getLabel(obj)
            value = char(getClassWithoutPackages(obj));
        end
    end
end
