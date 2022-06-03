classdef TemporalModulation < aod.builtin.protocols.SpectralProtocol

    properties
        temporalFrequency(1,1)      {mustBePositive}        = 5
        sinewave(1,1)               logical                 = true
    end

    properties (Dependent)
        temporalClass
    end

    methods
        function obj = TemporalModulation(stimTime, ledMeans, varargin)
            obj = obj@aod.builtin.protocols.SpectralProtocol(stimTime, ledMeans, varargin{:});

            ip = inputParser();
            ip.CaseSensitive = false;
            ip.KeepUnmatched = true;
            addParameter(ip, 'TemporalFrequency', 5, @isnumeric);
            addParameter(ip, 'Sinewave', true, @islogical);
            parse(ip, varargin{:});

            obj.temporalFrequency = ip.Results.TemporalFrequency;
            obj.sinewave = ip.Results.Sinewave;
        end

        function value = get.temporalClass(obj)
            if obj.sinewave
                value = 'sine';
            else
                value = 'square';
            end
        end
    end

    methods
        function stim = generate(obj)
            % GENERATE
            %
            % Syntax:
            %   stim = generate(obj)
            % -------------------------------------------------------------
            dt = 1 / obj.stimRate;
            t = 0:dt:obj.stimTime-dt;
            stim = sin(2*pi*obj.temporalFrequency*t);
            stim = obj.amplitude * stim;


            if obj.preTime > 0
                prePts = obj.sec2pts(obj.preTime);
                stim = [zeros(1, prePts), stim];
            end

            if obj.tailTime > 0
                tailPts = obj.sec2pts(obj.tailTime);
                stim = [stim, zeros(1, tailPts)];
            end
            stim = stim + obj.baseIntensity;
        end
        
        function fName = getFileName(obj)
            % GETFILENAME
            % 
            % Syntax:
            %   fName = getFileName(obj)
            % -------------------------------------------------------------
            fName = sprintf('luminance_%s_%uhz_%up_%ut_%s.txt',...
                obj.temporalClass, obj.temporalFrequency,...
                100*obj.baseIntensity, obj.totalTime,...
                datetime(datestr(now), 'Format', 'ddMMMuuuu'));
        end
    end
end
