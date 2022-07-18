classdef Chirp < patterson.protocols.SpectralProtocol
% CHIRP
%
% Description:
%   A sinusoidal modulation linearly increasing in temporal frequency
%
% Parent:
%   patterson.protocols.SpectralProtocol
%
% Constructor:
%   obj = Chirp(calibration, varargin)
%
% Properties:
%   startFreq                       First frequency (hz)
%   stopFreq                        Final frequency (hz)
%   reversed                        Reverse chirp (high to low freqs)
% Properties (inherited)
%   preTime
%   stimTime
%   tailTime
%   baseIntensity
%   contrast
%
% Reference:
%   Baden et al (2016) Nature
% -------------------------------------------------------------------------

    properties
        startFreq
        stopFreq
        reversed
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
            addParameter(ip, 'Reversed', false, @islogical);
            parse(ip, varargin{:});

            obj.startFreq = ip.Results.StartFreq;
            obj.stopFreq = ip.Results.StopFreq;
            obj.reversed = ip.Results.Reversed;
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

            if obj.reversed
                stim = flipud(stim);
            end

            % Add pre time and tail time
            stim = obj.appendPreTime(stim);
            stim = obj.appendTailTime(stim);
        end

        function ledValues = mapToStimulator(obj)
            ledValues = mapToStimulator@patterson.protocols.SpectralProtocol(obj);
        end

        function fName = getFileName(obj)
            % GETFILENAME
            %
            % Syntax:
            %   fName = getFileName(obj)
            % -------------------------------------------------------------
            if obj.reverse
                stimName = 'chirp';
            else
                stimName = 'reverse_chirp';
            end
            
            fName = sprintf('%s_%s_%us_%up_%ut',... 
                lower(char(obj.spectralClass)), stimName, obj.stimTime...
                100*obj.baseIntensity, floor(obj.totalTime));
        end
    end
end