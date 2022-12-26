classdef SpectralPhysiologyParameterReader < sara.readers.EpochParameterReader
% SPECTRALPHYSIOLOGYPARAMETERREADER
%
% Description:
%   Reads epoch parameter files and makes according adjustments to epoch
%
% Parent:
%   sara.readers.EpochParameterReader
%
% Constructor:
%   obj = SpectralPhysiologyParameterReader(fileName)
%   obj = SpectralPhysiologyParameterReader.init(filePath, ID)
% -------------------------------------------------------------------------

    methods
        function obj = SpectralPhysiologyParameterReader(fileName)
            obj@sara.readers.EpochParameterReader(fileName);
        end

        function epoch = readFile(obj, epoch)
            epoch = readFile@sara.readers.EpochParameterReader(obj, epoch);

            % If it's spectral physiology, then we know AOM1 was Mustang
            stim = sara.stimuli.Mustang(epoch.getParam('AOM1'));
            epoch.addStimulus(stim);

            % Reflectance window
            x = obj.readNumber('ReflectanceWindowX = ');
            y = obj.readNumber('ReflectanceWindowY = ');
            dx = obj.readNumber('ReflectanceWindowDX = ');
            dy = obj.readNumber('ReflectanceWindowDY = ');
            epoch.setParam('ReflectanceWindow', [x y dx dy]);

            % LED stimulus specifications
            epoch.setParam('LedInterval', obj.readNumber('Interval value = '));
            epoch.setParam('LedIntervalUnit', obj.readText('Interval unit = '));
            
            % LUT files (may not be necessary with Calibration class)
            epoch.setFile('LUT1', obj.readText('LUT1 = '));
            epoch.setFile('LUT2', obj.readText('LUT2 = '));
            epoch.setFile('LUT3', obj.readText('LUT3 = '));
        end
    end

    methods (Static)
        function epoch = read(fileName, epoch)
            obj = sara.readers.SpectralPhysiologyParameterReader(fileName);
            epoch = obj.readFile(epoch);
        end 
    end
end