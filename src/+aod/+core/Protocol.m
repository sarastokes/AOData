classdef (Abstract) Protocol < handle 
% PROTOCOL
%
% Syntax:
%   obj = aod.core.Protocol(stimTime, sampleRate, calibration, varargin)
%
% Properties:
%   preTime         time before stimulus in seconds
%   tailTime        time after stimulus in seconds
%
% Abstract methods:
%   stim = generate(obj)
%   writeStim(obj, fileName)
% -------------------------------------------------------------------------

    properties 
        stimTime             %{mustBePositive}                        = 1
        sampleRate           %{mustBePositive}                        = 25
        calibration

        preTime              % {mustBeNonnegative, mustBeInteger}      = 0
        tailTime             % {mustBeNonnegative, mustBeInteger}      = 0
    end

    properties (SetAccess = private)
        stimFrames 
        preFrames
        tailFrames
    end

    properties (Dependent, Access = protected)
        totalTime
    end

    methods (Abstract)
        stim = generate(obj)
        fName = getFileName(obj)
        writeStim(obj, fName)
    end

    methods
        function obj = Protocol(stimTime, sampleRate, varargin)
            obj.stimTime = stimTime;
            obj.sampleRate = sampleRate;
        
            ip = inputParser();
            ip.CaseSensitive = false;
            ip.KeepUnmatched = true;
            addParameter(ip, 'Calibration', []);
            addParameter(ip, 'PreTime', 0, @isnumeric);
            addParameter(ip, 'TailTime', 0, @isnumeric);
            parse(ip, varargin{:});
            
            obj.calibration = ip.Results.Calibration;
            obj.preTime = ip.Results.PreTime;
            obj.tailTime = ip.Results.TailTime;

            % Convert stimulus timing 
            obj.preFrames = obj.sec2pts(obj.preTime);
            obj.stimFrames = obj.sec2pts(obj.stimTime);
            obj.tailFrames = obj.sec2pts(obj.tailTime);
        end

        function value = get.totalTime(obj)
            value = obj.calculateTotalTime();
        end
    end

    methods (Access = protected)
        function value = calculateTotalTime(obj)
            % CALCULATETOTALTIME
            % Can be overwritten by subclasses if needed
            % -------------------------------------------------------------
            value = obj.preTime + obj.stimTime + obj.tailTime;
        end

        function value = sec2pts(obj, t)
            % SEC2PTS
            %
            % Syntax:
            %   value = sec2pts(obj, t)
            % -------------------------------------------------------------
            value = t * (1/obj.sampleRate);
        end

        function value = pts2sec(obj, pts)
            % PTS2SEC
            %
            % Syntax:
            %   value = pts2sec(obj, pts)
            % -------------------------------------------------------------
            value = floor(pts/obj.sampleRate);
        end
    end
end 