classdef IntensitySequence < sara.protocols.SpectralProtocol
% INTENSITYSEQUENCE
%
% Description:
%   A series of intensity steps
%
% Parent:
%   sara.protocols.spectral.ContrastSequence
%
% Constructor:
%   obj = IntensitySequence(calibration, varargin)
%
% Inherited properties:
%   stepTime                Time of each step (sec)
%   spectralClass
%   preTime
%   stimTime                Time of each step + return to baseline (sec)
%   tailTime
%   contrast                List of contrasts for each step (positive)
%   baseIntensity           Set to 0
%
% Derived properties:
%   numSteps                Number of steps presented
%
% Notes:
%   - Specialized subclass of sara.protcols.spectralContrastSequence,
%       the separation into a subclass isn't necessary, just for clarity
% -------------------------------------------------------------------------

    properties
        stepTime            % Time of each step + return to baseline (sec)
        intensity
    end

    properties (SetAccess = private)
        numSteps
    end

    methods
        function obj = IntensitySequence(calibration, varargin)
            obj = obj@sara.protocols.SpectralProtocol(...
                calibration, varargin{:});

            ip = aod.util.InputParser();
            addParameter(ip, 'StepTime', 5, @isnumeric);
            addParameter(ip, 'Intensity', [], @isnumeric);
            parse(ip, varargin{:});

            obj.intensity = ip.Results.Intensity;
            obj.stepTime = ip.Results.StepTime;


            % Input checking
            assert(nnz(obj.intensity < obj.baseIntensity) == 0,... 
                'Intensities are lower than baseIntensity');

            % Derived properties
            obj.numSteps = numel(obj.contrast);
            obj.contrast = (ip.Results.Intensity - obj.baseIntensity) ... 
                / obj.baseIntensity;
        end

        function stim = generate(obj)
            stim = obj.baseIntensity + zeros(1, obj.totalPoints);

            prePts = obj.sec2pts(obj.preTime);
            stimPts = obj.sec2pts(obj.stimTime);
            stepPts = obj.sec2pts(obj.stepTime);

            for i = 1:obj.numSteps
                stim(prePts+((i-1)*stimPts)+1:prePts+((i-1)*stimPts)+stepPts) = obj.intensity(i);
            end
        end

        function ledValues = mapToStimulator(obj)
            ledValues = mapToStimulator@sara.protocols.SpectralProtocol(obj);
        end

        function fName = getFileName(obj)
            fName = sprintf('%s_intensity_seq', lower(char(obj.spectralClass)));
            for i = 1:obj.numSteps
                fName = sprintf('%s_%ui', fName, round(100*obj.intensity(i)));
            end
            fName = sprintf('%s_%up_%us_%ut', fName,... 
                round(100*obj.baseIntensity), obj.stepTime, obj.totalTime);
        end
    end

    methods (Access = protected)
        function value = calculateTotalTime(obj)
            value = obj.preTime + (obj.numSteps * obj.stimTime) + obj.tailTime;
        end
    end
end 