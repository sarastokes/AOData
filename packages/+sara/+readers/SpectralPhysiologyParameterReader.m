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
%   obj = SpectralPhysiologyParameterReader(filePath, ID)
% -------------------------------------------------------------------------

    methods
        function obj = SpectralPhysiologyParameterReader(varargin)
            obj@sara.readers.EpochParameterReader(varargin{:});
        end

        function ep = read(obj, ep)
            ep = read@sara.readers.EpochParameterReader(obj, ep);

            % If it's spectral physiology, then we know AOM1 was Mustang
            stim = sara.stimuli.Mustang(ep.getParam('AOM1'));
            ep.addStimulus(stim);

            % Reflectance window
            x = obj.readNumber('ReflectanceWindowX = ');
            y = obj.readNumber('ReflectanceWindowY = ');
            dx = obj.readNumber('ReflectanceWindowDX = ');
            dy = obj.readNumber('ReflectanceWindowDY = ');
            ep.setParam('ReflectanceWindow', [x y dx dy]);

            % LED stimulus specifications
            ep.setParam('LedInterval', obj.readNumber('Interval value = '));
            ep.setParam('LedIntervalUnit', obj.readText('Interval unit = '));
            
            % LUT files (may not be necessary with Calibration class)
            ep.setFile('LUT1', obj.readText('LUT1 = '));
            ep.setFile('LUT2', obj.readText('LUT2 = '));
            ep.setFile('LUT3', obj.readText('LUT3 = '));
        end
    end
end