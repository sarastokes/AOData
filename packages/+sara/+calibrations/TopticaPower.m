classdef TopticaPower < aod.builtin.calibrations.PowerMeasurement 
% TOPTICAPOWER
%
% Description:
%   Power measurements for the Toptica laser
%
% Parent:
%   aod.builtin.calibrations.PowerMeasurement
%
% Constructor:
%   obj = TopticaPower(parent, calibrationDate, wavelength)
% -------------------------------------------------------------------------

    methods
        function obj = TopticaPower(parent, calibrationDate, wavelength)
            laserLines = [488, 515, 561, 630];
            assert(ismember(wavelength, laserLines), 'TopticaPower: Invalid laser line!');
            
            obj = obj@aod.builtin.calibrations.PowerMeasurement(parent,...
                calibrationDate, wavelength, 'SettingUnit', '%');
        end
    end
end 