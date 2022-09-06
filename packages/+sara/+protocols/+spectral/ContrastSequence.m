classdef ContrastSequence < sara.protocols.SpectralProtocol
% CONTRASTSEQUENCE
%
% Description:
%   Series of contrast increments and decrements
%
% Parent:
%   sara.protocols.SpectralProtocol
%
% Constructor:
%   obj = ContrastSequence(calibration, varargin)
%
% Properties:
%   stepTime                Time of each step (sec)
%
% Inherited properties:
%   spectralClass           sara.SpectralTypes
%   preTime
%   stimTime                Time of each step + return to baseline (sec)
%   tailTime
%   contrast                List of contrasts for each step
%   baseIntensity
%
% Derived properties:
%   numSteps                Number of steps presented
%
% See also:
%   sara.protocols.spectral.IntensitySeries
% -------------------------------------------------------------------------

    properties
        stepTime            % Time of each step + return to baseline (sec)
    end

    properties (SetAccess = private)
        numSteps
    end

    methods
        function obj = ContrastSequence(calibration, varargin)
            obj = obj@sara.protocols.SpectralProtocol(...
                calibration, varargin{:});
                
            ip = inputParser();
            ip.KeepUnmatched = true;
            ip.CaseSensitive = false;
            addParameter(ip, 'StepTime', 5, @isnumeric);
            addParameter(ip, 'Contrast', [0.2, -0.2, 0.5, -0.5, 1, -1], @isnumeric);
            addParameter(ip, 'BaseIntensity', 0.05, @isnumeric);
            parse(ip, varargin{:});

            obj.stepTime = ip.Results.StepTime;

            % Overwrites
            obj.contrast = ip.Results.Contrast;
            obj.baseIntensity = ip.Results.BaseIntensity;

            % Derived properties
            obj.numSteps = numel(obj.contrast);
        end

        function stim = generate(obj)
            stim = obj.baseIntensity + zeros(1, obj.totalPoints);

            prePts = obj.sec2pts(obj.preTime);
            stimPts = obj.sec2pts(obj.stimTime);
            stepPts = obj.sec2pts(obj.stepTime);

            for i = 1:obj.numSteps
                stim(prePts+((i-1)*stimPts)+1:prePts+((i-1)*stimPts)+stepPts) = obj.amplitude(i) + obj.baseIntensity;
            end
        end

        function ledValues = mapToStimulator(obj)
            ledValues = mapToStimulator@sara.protocols.SpectralProtocol(obj);
        end

        function fName = getFileName(obj)
            fName = 'contrast_seq_';
            for i = 1:numel(obj.contrast)
                if obj.contrast(i) > 0
                    fName = sprintf('%su%u_', fName, round(abs(100*obj.contrast(i))));
                else
                    fName = sprintf('%sd%u_', fName, round(abs(100*obj.contrast(i))));               
                end
            end
            fName = [fName, sprintf('%up_%us_%ut',... 
                round(100*obj.baseIntensity), obj.stepTime, obj.totalTime)];
        end
    end

    methods (Access = protected)
        function value = calculateTotalTime(obj)
            value = obj.preTime + (obj.numSteps * obj.stimTime) + obj.tailTime;
        end
    end
end