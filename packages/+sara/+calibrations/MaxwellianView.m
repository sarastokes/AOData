classdef MaxwellianView < aod.core.Calibration
% LEDCALIBRATION
%
% Description:
%   Calibration for the 3 LED Maxwellian View system
%
% Parent:
%   aod.core.Calibration
%
% Constructor:
%   obj = MaxwellianView(calibrationDate)
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
    end

    methods
        function obj = MaxwellianView(calibrationDate)
            obj = obj@aod.core.Calibration([], calibrationDate);

            obj.loadCalibrationFile()
        end

        function stim = calcStimulus(obj, whichStim, baseStim)
            if isa(whichStim, 'sara.SpectralTypes')
                whichStim = whichStim.getAbbrev();
            end

            dPower = obj.stimPowers.(whichStim)';
            bkgdPower = obj.stimPowers.Background';

            try
                stim = (dPower .* ((1/baseStim(1)) * (baseStim-baseStim(1))) + bkgdPower);
            catch
                stim = zeros(3, numel(baseStim));
                for i = 1:3
                    stim(i,:) = (dPower(i) .* ((1/baseStim(1)) * (baseStim-baseStim(1))) + bkgdPower(i));
                end
            end
        end
    end

    methods (Access = private)
        function loadCalibrationFile(obj)
            dataDir = [fileparts(fileparts(mfilename('fullpath'))),...
                filesep, '+resources', filesep];
            calibrationFile = [dataDir, 'LedCalibration', char(obj.calibrationDate), '.json'];
            S = loadjson(calibrationFile);

            obj.setFile('CalibrationFile', calibrationFile);
            
            obj.NDF = S.NDF;
            obj.ledMaxPowers = S.LedMaxPowers_uW;
            obj.ledBackgroundNorm = S.LedBackground_Norm;
            obj.meanChromaticity = S.MeanChromaticity_xyY;

            for i = 1:numel(S.Files.LUT)
                obj.setFile(sprintf('LUT%u',i), S.Files.LUT{i});
            end
            for i = 1:numel(S.Files.Spectra)
                obj.setFile(sprintf('Spectra%u',i), S.Files.Spectra{i});
            end
            
            obj.stimContrasts = rmfield(S.Stimuli.Contrasts, {'Labels', 'Units'});
            obj.stimContrasts = struct2table(structfun(@(x) x', obj.stimContrasts, 'UniformOutput', false));
            obj.stimPowers = rmfield(S.Stimuli.Powers, {'Labels', 'Units', 'Description'});
            obj.stimPowers = struct2table(structfun(@(x) x', obj.stimPowers, 'UniformOutput', false));

            obj.LUTs = table(S.LUTs.Voltages', S.LUTs.R', S.LUTs.G', S.LUTs.B',...
                'VariableNames', {'Voltage', 'R', 'G', 'B'});
            obj.spectra = table(S.Spectra.Wavelengths', S.Spectra.R',...
                S.Spectra.G', S.Spectra.B',...
                'VariableNames', {'Wavelength', 'R', 'G', 'B'});
        end
    end

    methods (Access = protected)
        function value = getLabel(obj)
            value = ['LedCalibration', char(obj.calibrationDate)];
        end
    end
end