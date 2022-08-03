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
%   obj = TopticaPower(laserLine, calibrationDate, parent)
% -------------------------------------------------------------------------
    methods
        function obj = TopticaPower(laserLine, varargin)
            obj = obj@aod.builtin.calibrations.PowerMeasurement(varargin{:});

            obj.wavelength = laserLine;
            obj.settingUnit = 'Normalized';
        end
    end
end 