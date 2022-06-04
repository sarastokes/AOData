classdef (Abstract) Protocol < handle 
% PROTOCOL
%
% Syntax:
%   obj = aod.core.Protocol(stimTime, calibration, varargin)
%
% Properties:
%   preTime         time before stimulus in seconds
%   tailTime        time after stimulus in seconds
%
% Abstract properties (must be set by subclasses):
%   sampleRate      the rate data is sampled (hz)
%   stimRate        the rate stimuli are presented (hz)
%
% Dependent properties:
%   totalTime       total stimulus time (from calculateTotalTime)
%   totalSamples    total number of samples in stimulus
%
% Abstract methods:
%   stim = generate(obj)
%   fName = getFileName(obj)
%   writeStim(obj, fileName)
%
% Protected methods:
%   value = calculateTotalTime(obj)
% -------------------------------------------------------------------------

    properties 
        stimTime   
        calibration

        preTime   
        tailTime 
    end

    properties (Dependent)
        totalTime
        totalSamples
    end

    properties (Abstract, SetAccess = protected)
        sampleRate
        stimRate
    end

    methods (Abstract)
        stim = generate(obj)
        fName = getFileName(obj)
        writeStim(obj, fName)
    end

    methods
        function obj = Protocol(varargin)
        
            ip = inputParser();
            ip.CaseSensitive = false;
            ip.KeepUnmatched = true;
            addParameter(ip, 'Calibration', []);
            addParameter(ip, 'PreTime', 0, @isnumeric);
            addParameter(ip, 'StimTime', 0, @isnumeric);
            addParameter(ip, 'TailTime', 0, @isnumeric);
            parse(ip, varargin{:});
            
            obj.calibration = ip.Results.Calibration;
            obj.preTime = ip.Results.PreTime;
            obj.stimTime = ip.Results.StimTime;
            obj.tailTime = ip.Results.TailTime;
        end

        function value = get.totalTime(obj)
            value = obj.calculateTotalTime();
        end

        function value = get.totalSamples(obj)
            value = obj.sec2samples(obj.totalTime);
        end
    end

    methods
        function stim = mapToStimulator(obj)
            % MAPTOSTIMULATOR
            % Can be overwritten by subclasses if needed
            % -------------------------------------------------------------
            stim = obj.generate();
        end
    end

    methods (Access = protected)
        function value = calculateTotalTime(obj)
            % CALCULATETOTALTIME
            % Can be overwritten by subclasses if needed
            % -------------------------------------------------------------
            value = obj.preTime + obj.stimTime + obj.tailTime;
        end
    end

    % Convenience methods
    methods (Access = protected)
        function value = sec2pts(obj, t)
            % SEC2PTS
            %
            % Syntax:
            %   value = sec2pts(obj, t)
            % -------------------------------------------------------------
            value = floor(t * obj.stimRate);
        end

        function value = pts2sec(obj, pts)
            % PTS2SEC
            %
            % Syntax:
            %   value = pts2sec(obj, pts)
            % -------------------------------------------------------------
            value = floor(pts/obj.stimRate);
        end

        function value = sec2samples(obj, t)
            % SEC2PTS
            %
            % Syntax:
            %   value = sec2samples(obj, t)
            % -------------------------------------------------------------
            value = floor(t * obj.sampleRate);
        end

        function value = samples2pts(obj, pts)
            % PTS2SEC
            %
            % Syntax:
            %   value = samples2sec(obj, pts)
            % -------------------------------------------------------------
            value = floor(pts/obj.sampleRate);
        end

        function stim = appendPreTime(obj, stim)
            % APPENDPRETIME
            %
            % Syntax:
            %   stim = obj.appendPreTime(stim)
            % -------------------------------------------------------------
            if obj.preTime > 0
                stim = [obj.baseIntensity+zeros(1, obj.sec2pts(obj.preTime)), stim];
            end
        end

        function stim = appendTailTime(obj, stim)
            % APPENDTAILTIME
            %
            % Syntax:
            %   stim = obj.appendTailTime(stim)
            % -------------------------------------------------------------
            if obj.tailTime > 0
                stim = [stim, obj.baseIntensity+zeros(1, obj.sec2pts(obj.tailTime))];
            end
        end
    end
end 