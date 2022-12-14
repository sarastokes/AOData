classdef ScannerSimulation < sara.protocols.spectral.Pulse 
% SCANNERSIMULATION
%
% Presents stimulus modulated temporally as if through a scanning system
%
% Constructor:
%   obj = ScannerSimulation(calibration, varargin)
%
% Parent:
%   sara.protocols.spectral.Pulse
%
% Properties
%   pulseTime                           Pulse time (ms)
%   scannerRate                         Stim rate to simulate (hz)
% Inherited properties:
%   See aod.builtin.protocols.StimulusProtocol
%
% Notes:
%   - Include a long preTime for adaptation
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        stimPoints
    end

    properties (Constant)
        pulseTime = 4;                  % Pulse time (ms)
        scannerRate = 25                % Stim rate to simulate (hz)
    end

    methods
        function obj = ScannerSimulation(calibration, varargin)
            obj = obj@sara.protocols.spectral.Pulse(...
                calibration, varargin{:});

            % Input checking
            if obj.spectralClass.isConeIsolating
                error('Cone isolation not supported!');
            end
        end

        function stim = generate(obj)

            frameTime_ms = 1 / obj.scannerRate * 1000;     % ms
            stimTime_ms = 1 / obj.stimRate * 1000;         % ms

            framePoints = frameTime_ms / stimTime_ms;

            numReps = ceil(obj.sec2pts(obj.totalTime) / framePoints);

            scanner = zeros(1, framePoints);
            scanner(end) = obj.baseIntensity;

            stim = repmat(scanner, [1 numReps]);
            if obj.contrast > 0            
                modTime = [obj.preTime, obj.preTime+obj.stimTime];
                modPoints = modTime * obj.stimRate;
                idx = find(stim > 0);
                idx = idx(idx > modPoints(1) & idx <= modPoints(2));
                stim(idx) = obj.amplitude + obj.baseIntensity;
            end
        end

        function ledValues = mapToStimulator(obj)
            ledValues = mapToStimulator@sara.protocols.SpectralProtocol(obj);
        end

        function fName = getFileName(obj)
            if obj.contrast ~= 0
                [a, b] = sara.util.parseModulation(obj.baseIntensity, obj.contrast);
                fName = sprintf('scannersim_%s_%s_%s_%us_%ua_%ut',...
                    a, b, lower(char(obj.spectralClass)),... 
                    obj.stimTime, obj.preTime, obj.totalTime);
            else
                fName = sprintf('scannersim_%s_baseline_%ut',...
                    lower(char(obj.spectralClass)), obj.totalTime);
            end
        end
    end
end 