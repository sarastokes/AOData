classdef Steps < sara.protocols.SpectralProtocol
% STEPS
%
% Description:
%   A series of contrast increments and decrements
%
% Parent:
%   sara.protocols.SpectralProtocol
%
% Notes:
%   Similar to TemporalModulation but with a slightly different stimulus 
%   setup (define time of each step rather than temporal frequency, only
%   squarewaves are created)
% -------------------------------------------------------------------------

    properties
        stepTime(1,1)           {mustBePositive} = 20
        numSteps(1,1)           {mustBeInteger} = 5
        firstContrast(1,1)      {mustBeInRange(firstContrast, -1, 1)} = -1
    end

    properties (SetAccess = private)
        contrasts
        stimWindows
    end

    methods
        function obj = Steps(calibration, varargin)
            obj = obj@sara.protocols.SpectralProtocol(...
                calibration, varargin{:});

            ip = inputParser();
            ip.KeepUnmatched = true;
            ip.CaseSensitive = false;
            addParameter(ip, 'StepTime', 20, @isnumeric);
            addParameter(ip, 'NumSteps', 5, @isnumeric);
            addParameter(ip, 'FirstContrast', -1, @isnumeric);
            parse(ip, varargin{:});
            
            obj.stimTime = ip.Results.NumSteps * ip.Results.StepTime;

            obj.stepTime = ip.Results.StepTime;
            obj.numSteps = ip.Results.NumSteps;
            obj.firstContrast = ip.Results.FirstContrast;

            % Derived properties
            obj.contrasts = zeros(1,obj.numSteps);
            obj.contrasts(1) = obj.firstContrast;
            for i = 2:obj.numSteps
                obj.contrasts(i) = -1 * obj.contrasts(i-1);
            end

            obj.stimWindows = zeros(obj.numSteps, 2);
            stepPts = obj.sec2pts(obj.stepTime);
            prePts = obj.sec2pts(obj.preTime);
            for i = 1:obj.numSteps
                offset = prePts + ((i-1)*stepPts);
                obj.stimWindows(i, :) = [offset+1, offset+stepPts];
            end
            obj.stimTime = obj.stepTime * numel(obj.contrasts);
        end

        function stim = generate(obj)
            stim = obj.baseIntensity + zeros(1, obj.totalPoints);
            for i = 1:obj.numSteps
                stim(window2idx(obj.stimWindows(i,:))) = ...
                    obj.baseIntensity + (sign(obj.contrasts(i)) * obj.amplitude);
            end
        end

        function ledValues = mapToStimulator(obj)
            ledValues = mapToStimulator@sara.protocols.SpectralProtocol(obj);
        end

        function fName = getFileName(obj)
            if obj.numSteps == 2 && obj.firstContrast < 0
                fName = sprintf('%s_decrement_increment_%us_%uc_%up_%ut',...
                    lower(char(obj.spectralClass)), obj.stepTime,... 
                    round(100*obj.contrast), round(100*obj.baseIntensity),... 
                    obj.totalTime);
            else
                fName = sprintf('%s_square_%us_%uc_%up_%ut.txt',...
                    lower(char(obj.spectralClass)), obj.stepTime,... 
                    round(100*obj.contrast), round(100*obj.baseIntensity),... 
                    obj.totalTime);
            end
        end
    end

    methods (Access = protected)
        function value = calculateTotalTime(obj)
            value = obj.preTime + (obj.numSteps*obj.stepTime) + obj.tailTime;
        end
    end
end