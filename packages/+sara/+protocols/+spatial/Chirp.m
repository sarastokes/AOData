classdef Chirp < sara.protocols.SpatialProtocol 
% CHIRP
%
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
            obj = obj@sara.protocols.SpatialProtocol(calibration, varargin{:});
        
            ip = inputParser();
            ip.CaseSensitive = false;
            ip.KeepUnmatched = true;
            addParameter(ip, 'StartFreq', 0.5, @isnumeric);
            addParameter(ip, 'StopFreq', 8, @isnumeric);
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
                stim = fliplr(stim);
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
            if obj.reversed
                stimName = 'chirp';
            else
                stimName = 'reverse_chirp';
            end
            
            fName = sprintf('%s_%us_%up_%ut', stimName, obj.stimTime,...
                100*obj.baseIntensity, floor(obj.totalTime));
        end

        function trace = temporalTrace(obj)
            trace = obj.generate();
        end

        function h = plotTemporalTrace(obj, varargin)
            trace = obj.temporalTrace();
            h = plotTemporalTrace@sara.protocols.SpatialProtocol(obj, trace);
        end
    end
end