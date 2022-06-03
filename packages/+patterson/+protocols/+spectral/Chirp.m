classdef Chirp < aod.builtin.protocols.SpectralProtocol
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
        function obj = Chirp(ledMeans, varargin)
            obj = obj@aod.builtin.protocols.SpectralProtocol(ledMeans, varargin{:});

            ip = inputParser();
            addParameter(ip, 'StartFreq', 0.5, @isnumeric);
            addParameter(ip, 'StopFreq', 30, @isnumeric);
            parse(ip, varargin{:});

            obj.startFreq = ip.Results.StartFreq;
            obj.stopFreq = ip.Results.StopFreq;
        end
        
        function stim = generate(obj)
            ledResolution = 1/obj.stimRate;  % ms
            chirpPts = obj.freqTime / ledResolution;
            hzPerSec = obj.stopFreq / obj.freqTime;

            stim = zeros(1, chirpPts);
            for i = 1:chirpPts
                stim(i) = sin(pi*hzPerSec*(i*ledResolution)^2)...
                    * obj.baseIntensity + obj.baseIntensity;
            end

            % Add pre time and tail time
            stim = obj.appendPreTime(stim);
            stim = obj.appendTailTime(stim);
        end

        function fName = getFileName(obj)
            % GETFILENAME
            %
            % Syntax:
            %   fName = getFileName(obj)
            % -------------------------------------------------------------
            fName = sprintf('chirp_%ut_%s', floor(obj.totalTime),...
                getTodaysDate());
        end
    end
end