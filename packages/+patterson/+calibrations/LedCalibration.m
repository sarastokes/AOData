classdef LedCalibration < aod.core.Calibration
% LEDCALIBRATION
%
% Description:
%   Calibration for the 3 LED Maxwellian View system
%
% Constructor:
%   obj = patterson.calibrations.LedCalibration(calibrationDate, parent)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        NDF
        ledMaxPowers
        ledBackgroundNorm
        stimPowers
        stimContrasts
        meanChromaticity
        LUTs
        spectra

        spectraFiles
        lutFiles

        calibrationFile
    end

    methods
        function obj = LedCalibration(calibrationDate, parent)
            if nargin < 2
                parent = [];
            end
            obj = obj@aod.core.Calibration(calibrationDate, parent);

            obj.loadCalibrationFile()
        end
    end

    methods (Access = private)
        function loadCalibrationFile(obj)
            dataDir = [fileparts(fileparts(mfilename('fullpath'))),...
                filesep, '+resources', filesep];
            obj.calibrationFile = [dataDir, 'LedCalibration', char(obj.calibrationDate), '.json'];
            S = loadjson(obj.calibrationFile);
            
            obj.NDF = S.NDF;
            obj.ledMaxPowers = S.LedMaxPowers_uW;
            obj.ledBackgroundNorm = S.LedBackground_Norm;
            obj.meanChromaticity = S.MeanChromaticity_xyY;
            
            obj.spectraFiles = S.Files.Spectra;
            obj.lutFiles = S.Files.LUT;
            obj.stimContrasts = S.Stimuli.Contrasts;
            obj.stimPowers = S.Stimuli.Powers;

            obj.LUTs = table(S.LUTs.Voltages', S.LUTs.R', S.LUTs.G', S.LUTs.B',...
                'VariableNames', {'Voltage', 'R', 'G', 'B'});
            obj.spectra = table(S.Spectra.Wavelengths', S.Spectra.R',...
                S.Spectra.G', S.Spectra.B',...
                'VariableNames', {'Wavleength', 'R', 'G', 'B'});
        end
    end

    methods (Access = protected)
        function value = getLabel(obj)
            value = ['LedCalibration', char(obj.calibrationDate)];
        end
    end
end