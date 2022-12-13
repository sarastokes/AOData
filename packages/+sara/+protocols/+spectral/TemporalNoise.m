classdef TemporalNoise < sara.protocols.SpectralProtocol  

    properties 
        noiseType = 'binary';
        dwell = 1
        seed
    end

    methods
        function obj = TemporalNoise(calibration, varargin)
            obj = obj@sara.protocols.SpectralProtocol(...
                calibration, varargin{:});
            
            ip = inputParser();
            ip.CaseSensitive = false;
            ip.KeepUnmatched = true;
            addParameter(ip, 'Dwell', 1, @isnumeric);
            addParameter(ip, 'Seed', 16, @isnumeric);
            parse(ip, varargin{:});

            obj.seed = ip.Results.Seed;
            obj.dwell = ip.Results.Dwell;
        end

        function stim = generate(obj)
            noiseStream = RandStream('mt19937ar', 'Seed', obj.seed);
            noisePts = obj.sec2pts(obj.stimTime) / obj.sec2pts(obj.dwell);

            stim = 2 * obj.baseIntensity * double(noiseStream.rand(1, noisePts)> 0.5);

            stim = repelem(stim, obj.sec2pts(obj.dwell));

            stim = obj.appendPreTime(stim);
            stim = obj.appendTailTime(stim);
        end

        function ledValues = mapToStimulator(obj)
            ledValues = mapToStimulator@sara.protocols.SpectralProtocol(obj);
        end

        function fName = getFileName(obj)
            % GETFILENAME
            %
            % Syntax:
            %   fName = getFileName(obj)
            % -------------------------------------------------------------
            
            fName = sprintf('%s_%sNoise_%ud_%useed_%us_%up_%ut',... 
                lower(char(obj.spectralClass)), obj.noiseType, 100*obj.dwell,...
                obj.seed, obj.stimTime, 100*obj.baseIntensity, floor(obj.totalTime));
        end
    end
end