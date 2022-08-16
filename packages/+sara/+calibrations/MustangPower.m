classdef MustangPower < aod.builtin.calibrations.PowerMeasurement 
% MUSTANGPOWER
%
% Description:
%   Power measurements of Mustang laser
%
% Parent:
%   aod.builtin.calibrations.PowerMeasurement(parent, calibrationDate)
%
% Constructor:
%   obj = MustangPower(calibrationDate, parent);
% -------------------------------------------------------------------------

    methods
        function obj = MustangPower(parent, calibrationDate)
            obj = obj@aod.builtin.calibrations.PowerMeasurement(parent,...
                calibrationDate, 488, 'SettingUnit', 'Normalized');
        end
    end
end 