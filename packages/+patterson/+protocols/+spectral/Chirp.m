classdef Chirp < patterson.protocols.SpectralProtocol
% CHIRP
%
% Description:
%   A sinusoidal modulation linearly increasing in temporal frequency
%
% Properties:
%   preTime
%   stimTime
%   tailTime
%   baseIntensity
%   contrast
%   startFreq
%   stopFreq
%
% Reference:
%   Baden et al (2016) Nature
% -------------------------------------------------------------------------

    properties
        startFreq
        stopFreq
    end

    methods
        function obj = Chirp(calibration, varargin)
            obj = obj@patterson.protocols.SpectralProtocol(...
                calibration, varargin{:});

            ip = inputParser();
            ip.CaseSensitive = false;
            ip.KeepUnmatched = true;
            addParameter(ip, 'StartFreq', 0.5, @isnumeric);
            addParameter(ip, 'StopFreq', 30, @isnumeric);
            parse(ip, varargin{:});

            obj.startFreq = ip.Results.StartFreq;
            obj.stopFreq = ip.Results.StopFreq;
        end
        
        function stim = generate(obj)
            sampleTime = 1/obj.stimRate;  % sec
            chirpPts = obj.sec2pts(obj.stimTime);
            hzPerSec = obj.stopFreq / obj.stimTime;

            stim = zeros(1, chirpPts);
            for i = 1:chirpPts
                x = i*sampleTime;
                stim(i) = sin(pi*hzPerSec*x^2)...
                    * obj.baseIntensity + obj.baseIntensity;
            end

            % Add pre time and tail time
            stim = obj.appendPreTime(stim);
            stim = obj.appendTailTime(stim);
        end

        function trace = temporalTrace(obj)
            trace = obj.generate();
        end

        function fName = getFileName(obj)
            % GETFILENAME
            %
            % Syntax:
            %   fName = getFileName(obj)
            % -------------------------------------------------------------
            fName = sprintf('%s_chirp_%up_%ut_%s', lower(char(obj.spectralClass)),...
                100*obj.baseIntensity, floor(obj.totalTime), getTodaysDate());
        end
    end
end