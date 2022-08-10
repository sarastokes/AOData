classdef MustangPower < aod.builtin.calibrations.PowerMeasurement 
% MUSTANGPOWER
%
% Description:
%   Power measurements of Mustang laser
%
% Parent:
%   aod.builtin.calibrations.PowerMeasurement(calibrationDate, parent)
%
% Constructor:
%   obj = MustangPower(calibrationDate, parent);
% -------------------------------------------------------------------------

    methods
        function obj = MustangPower(varargin)
            obj = obj@aod.builtin.calibrations.PowerMeasurement(varargin{:});

            obj.wavelength = 488;
            obj.settingUnit = 'Normalized';
        end
    end
end 