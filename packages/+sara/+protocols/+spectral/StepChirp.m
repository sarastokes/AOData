classdef StepChirp < sara.protocols.spectral.Chirp
% STEPCHIRP
%
% Description:
%   Contrast step(s) followed by a chirp
%
% Parent:
%   sara.protocols.SpectralProtocol
%
% Constructor:
%   obj = Chirp(calibration, varargin)
%
% Properties:
%   stepTime                        Time of each individual step
%   intervalTime                    Time between step(s) and chirp (sec)
% Properties (inherited)
%   startFreq                       First frequency (hz)
%   stopFreq                        Final frequency (hz)
%   reversed                        Reverse chirp (high to low freqs)
%   preTime
%   stimTime
%   tailTime
%   baseIntensity
%   contrast
%
% Derived properties:
%   numSteps
%
% Reference:
%   Baden et al (2016) Nature
% -------------------------------------------------------------------------

    properties
        stepTime                % Time of step/steps (sec)
        intervalTime            % Time between step(s) and chirp (sec)
    end

    properties (Access = private)
        numSteps
    end

    methods
        function obj = StepChirp(calibration, varargin)
            obj = obj@sara.protocols.spectral.Chirp(...
                calibration, varargin{:});
            
            ip = inputParser();
            ip.KeepUnmatched = true;
            ip.CaseSensitive = false;
            addParameter(ip, 'StepTime', 5, @isnumeric);
            addParameter(ip, 'IntervalTime', 15, @isnumeric);
            addParameter(ip, 'Contrast', [-1, 1], @isnumeric);
            parse(ip, varargin{:});

            obj.stepTime = ip.Results.StepTime;
            obj.intervalTime = ip.Results.IntervalTime;

            % Overwrites
            obj.contrast = ip.Results.Contrast;
            
            % Derived properties
            obj.numSteps = numel(obj.contrast);
        end

        function stim = generate(obj)
            stim = generate@sara.protocols.spectral.Chirp(obj);

            prePts = obj.sec2pts(obj.preTime);
            stepPts = obj.sec2pts(obj.stepTime);

            stim = stim(prePts+1:end);

            stepStim = obj.baseIntensity + zeros(1, obj.sec2pts(obj.preTime + (obj.numSteps*obj.stepTime) + obj.intervalTime));

            for i = 1:obj.numSteps
                stepStim(prePts+((i-1)*stepPts)+1:prePts+(i*stepPts)) = obj.amplitude(i) + obj.baseIntensity;
            end

            stim = [stepStim, stim];
        end

        function fName = getFileName(obj)
            if obj.reversed
                stimName = 'chirp';
            else
                stimName = 'reverse_chirp';
            end
            fName = sprintf('%s_%s_step%us_%us_%up_%ut',... 
                lower(char(obj.spectralClass)), stimName, obj.numSteps*obj.stepTime, obj.stimTime,...
                100*obj.baseIntensity, floor(obj.totalTime));
        end
    end

    methods (Access = protected)
        function value = calculateTotalTime(obj)
            value = obj.preTime + (obj.numSteps*obj.stepTime) + ...
                obj.intervalTime + obj.stimTime + obj.tailTime;
        end
    end
end 