classdef MustangPower < aod.builtin.calibrations.PowerMeasurement 
% MUSTANGPOWER
%
% Description:
%   Power measurements of Mustang laser
%
% Parent:
%   aod.builtin.calibrations.PowerMeasurement(calibrationDate)
%
% Constructor:
%   obj = MustangPower(calibrationDate, parent);
% -------------------------------------------------------------------------

    methods
        function obj = MustangPower(calibrationDate)
            obj = obj@aod.builtin.calibrations.PowerMeasurement(...
                [], calibrationDate, 488, 'SettingUnit', 'Normalized');
        end
    end
end 