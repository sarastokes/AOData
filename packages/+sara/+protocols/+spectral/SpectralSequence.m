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
%   pulseTime                   Time of each pulse in spectral series
% Inherited properties:
%   preTime
%   stimTime                    Time for each pulse (pulse + baseline)
%   tailTime        
%   baseIntensity
%   contrast
%
% Derived properties:
%   interpulseTime              Time b/w pulses (stimTime-pulseTime)
%   numPulses                   Number of letters in sequence
% -------------------------------------------------------------------------

    properties
        sequence
        pulseTime
    end

    properties (SetAccess = protected)
        numPulses
        interpulseTime 
    end

    methods
        function obj = SpectralSequence(calibration, varargin)
            obj = obj@sara.protocols.SpectralProtocol(...
                calibration, varargin{:});
            
            ip = inputParser();
            ip.CaseSensitive = false;
            ip.KeepUnmatched = true;
            addParameter(ip, 'Intensity', 0.75, @isnumeric);
            addParameter(ip, 'Sequence', 'RGW', @ischar);
            addParameter(ip, 'PulseTime', 5, @isnumeric);
            parse(ip, varargin{:});

            obj.sequence = ip.Results.Sequence;
            obj.pulseTime = ip.Results.PulseTime;

            % Override default parameters
            obj.spectralClass = sara.SpectralTypes.Generic;

            % Derived properties
            obj.numPulses = numel(obj.sequence);
            obj.interpulseTime = obj.stimTime - obj.pulseTime;
        end
    end

    methods 
        function stim = generate(obj)
            stim = zeros(1, obj.totalPoints);
            prePts = obj.sec2pts(obj.preTime);
            stimPts = obj.sec2pts(obj.stimTime);
            pulsePts = obj.sec2pts(obj.pulseTime);

            for i = 1:obj.numPulses
                stim(prePts+((i-1)*stimPts)+1 : prePts+((i-1)*stimPts)+pulsePts) = ...
                    obj.amplitude + obj.baseIntensity;
            end
        end

        function ledValues = mapToStimulator(obj)
            stim = obj.generate();
            ups = getModulationTimes(stim);
            bkgdPowers = obj.calibration.stimPowers.Background;

            spectralClasses = [];
            for i = 1:obj.numPulses
                spectralClasses = cat(1, spectralClasses,...
                    sara.SpectralTypes.init(obj.sequence(i)));
            end

            ledValues = obj.baseIntensity * repmat(bkgdPowers', [1 numel(stim)]);
            for i = 1:obj.numPulses
                ledTargets = find(spectralClasses(i).whichLEDs());
                for j = 1:numel(ledTargets)
                    ledValues(ledTargets(j), window2idx(ups(i,:))) = ...
                        obj.contrast * 2*bkgdPowers(j);
                end
            end
        end

        function fName = getFileName(obj)
            fName = sprintf('%s_seq_%us_%um_%up_%ut',...
                lower(obj.sequence), obj.pulseTime, 100*obj.contrast,...
                100*obj.baseIntensity, obj.totalTime);
        end

    end

    methods (Access = protected)
        function value = calculateTotalTime(obj)
            value = obj.preTime + (obj.numPulses*obj.stimTime) + obj.tailTime;
        end

        function value = calculateAmplitude(obj)
            value = obj.contrast;
        end
    end
end 