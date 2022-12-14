classdef SpectralSequence < sara.protocols.SpectralProtocol
% SPECTRALSEQUENCE
%
% Definition:
%   A series of LED-specific pulses
%
% Parent:
%   sara.protocols.SpectralProtocol
%
% Constructor:
%   obj = SpectralProtocol(calibration, varargin)
% 
% Properties:
%   sequence                    LED sequence (e.g. 'RGW', 'BYW')
%   stepTime                    Time of each pulse in spectral series
%   intensity                   Intensity of individual pulses (0-1)
%   lumNorm                     normalize LED modulations to white point
% Inherited properties:
%   preTime
%   stimTime                    Time for each pulse (pulse + baseline)
%   tailTime        
%   baseIntensity
%   contrast
%
% Derived properties:
%   interpulseTime              Time b/w pulses (stimTime-pulseTime)
%   numSteps                    Number of letters in sequence
% -------------------------------------------------------------------------

    properties
        sequence
        stepTime        double = 5
        intensity
        lumNorm         logical = true
    end

    properties% (SetAccess = protected)
        numSteps
        interpulseTime 
    end

    methods
        function obj = SpectralSequence(calibration, varargin)
            obj = obj@sara.protocols.SpectralProtocol(...
                calibration, varargin{:});
            
            ip = aod.util.InputParser();
            addParameter(ip, 'Intensity', 0.75, @isnumeric);
            addParameter(ip, 'Sequence', 'RGW', @ischar);
            addParameter(ip, 'StepTime', 5, @isnumeric);
            addParameter(ip, 'Norm', true, @islogical);
            parse(ip, varargin{:});

            obj.sequence = ip.Results.Sequence;
            obj.stepTime = ip.Results.StepTime;
            obj.intensity = ip.Results.Intensity;
            obj.lumNorm = ip.Results.Norm;

            % Override default parameters
            obj.spectralClass = sara.SpectralTypes.Generic;

            % Derived properties
            obj.numSteps = numel(obj.sequence);
            obj.interpulseTime = obj.stimTime - obj.stepTime;
        end
    end

    methods 
        function stim = generate(obj)
            stim = obj.baseIntensity + zeros(1, obj.totalPoints);
            prePts = obj.sec2pts(obj.preTime);
            stimPts = obj.sec2pts(obj.stimTime);
            stepPts = obj.sec2pts(obj.stepTime);

            for i = 1:obj.numSteps
                stim(prePts+((i-1)*stimPts)+1 : prePts+((i-1)*stimPts)+stepPts) = ...
                    obj.amplitude + obj.baseIntensity;
            end
        end

        function ledValues = mapToStimulator(obj)
            stim = obj.generate();
            ups = sara.util.getModulationTimes(stim);
            if obj.lumNorm
                bkgdPowers = obj.Calibration.stimPowers.Background;
            else
                bkgdPowers = obj.Calibration.ledMaxPowers' / 2;
            end

            spectralClasses = [];
            for i = 1:obj.numSteps
                spectralClasses = cat(1, spectralClasses,...
                    sara.SpectralTypes.init(obj.sequence(i)));
            end

            ledValues = obj.baseIntensity * repmat(bkgdPowers, [1 numel(stim)]);
            for i = 1:obj.numSteps
                ledTargets = find(spectralClasses(i).whichLEDs());
                for j = 1:numel(ledTargets)
                    ledValues(ledTargets(j), window2idx(ups(i,:))) = ...
                        obj.intensity * bkgdPowers(ledTargets(j));
                end
            end
        end

        function fName = getFileName(obj)
            if obj.lumNorm
                lumTxt = '';
            else
                lumTxt = '_raw';
            end
            fName = sprintf('%s_seq_%us_%um%s_%up_%ut',...
                lower(obj.sequence), obj.stepTime, round(100*obj.intensity),...
                lumTxt, round(100*obj.baseIntensity), obj.totalTime);
        end

    end

    methods (Access = protected)
        function value = calculateTotalTime(obj)
            value = obj.preTime + (obj.numSteps*obj.stimTime) + obj.tailTime;
        end

        function value = calculateAmplitude(obj)
            value = obj.contrast;
        end
    end
end 