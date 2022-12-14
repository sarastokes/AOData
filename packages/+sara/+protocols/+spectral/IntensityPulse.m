classdef IntensityPulse < sara.protocols.SpectralProtocol

    properties
        intensity
        lumNorm         logical = true
    end

    methods 
        function obj = IntensityPulse(calibration, varargin)
            obj = obj@sara.protocols.SpectralProtocol(...
                calibration, varargin{:});
            
            ip = aod.util.InputParser();
            addParameter(ip, 'Intensity', 0.75, @isnumeric);
            addParameter(ip, 'Norm', true, @islogical);
            parse(ip, varargin{:});

            obj.intensity = ip.Results.Intensity;
            obj.lumNorm = ip.Results.Norm;
            
        end
    end

    methods
        function stim = generate(obj)
            stim = obj.baseIntensity + zeros(1, obj.totalPoints);

            prePts = obj.sec2pts(obj.preTime);
            stimPts = obj.sec2pts(obj.stimTime);
            stim(prePts+1:prePts+stimPts) = obj.amplitude + obj.baseIntensity;
        end

        function ledValues = mapToStimulator(obj)
            stim = obj.generate();

            ups = sara.util.getModulationTimes(stim);
            if obj.lumNorm
                bkgdPowers = obj.Calibration.stimPowers.Background;
            else
                bkgdPowers = obj.Calibration.ledMaxPowers' / 2;
            end

            ledValues = obj.baseIntensity * repmat(bkgdPowers, [1 numel(stim)]);
            ledTargets = find(obj.spectralClass.whichLEDs);
            for i = 1:numel(ledTargets)
                ledValues(ledTargets(i), window2idx(ups)) = ...
                    obj.intensity * bkgdPowers(ledTargets(i));
            end
        end

        function fName = getFileName(obj)

            if obj.lumNorm
                lumTxt = '';
            else
                lumTxt = '_raw';
            end

            fName = sprintf('%s_increment_%ui%s_%us_%up_%ut',...
                lower(char(obj.spectralClass)),...
                round(100*obj.intensity), lumTxt, obj.stimTime,...
                round(100*obj.baseIntensity), obj.totalTime);
        end
    end

end