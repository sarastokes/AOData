classdef (Abstract) StimulusProtocol < aod.core.Protocol
% STIMULUSPROTOCOL (abstract)
%
% Description:
%   A protocol presenting a visual stimulus 
%
% Parent:
%   aod.core.Protocol
%
% Constructor:
%   obj = StimulusProtocol(calibration, varargin)
%
% Properties:
%   preTime                 time before stimulus in seconds
%   stimTime                time during stimulus
%   tailTime                time after stimulus in seconds
%   baseIntensity (0-1)     baseline intensity of stimulus
%   contrast (0-1)          scaling applied during stimTime
%                           - computed as contrast if baseIntensity > 0
%                           - computed as intensity if baseIntensity = 0
%
% Dependent properties:
%   totalTime               total stimulus time (from calculateTotalTime)
%   totalSamples            total number of samples in stimulus
%   totalPoints             total number of time points in stimulus
%   amplitude               computed from contrast as described above
%
% Protected properties:
%   groupBy             optional hierarchy of parameters for grouping 
%
% Methods:
%   trace = temporalTrace(obj) 
%   plotTemporalTrace(obj)
%
% Protected methods:
%   value = calculateTotalTime(obj)
%   value = calculateAmplitude(obj)
% -------------------------------------------------------------------------
    properties
        preTime  
        stimTime   
        tailTime 
        baseIntensity
        contrast
    end
    
    properties (SetAccess = protected)
        groupBy             = cell.empty()
    end

    properties (Dependent)
        totalTime
        totalSamples
        totalPoints
        amplitude
    end

    methods
        function obj = StimulusProtocol(calibration, varargin)
            obj = obj@aod.core.Protocol(calibration);

            obj.groupBy = {'baseIntensity', 'contrast'};

             % Input parsing
            ip = inputParser();
            ip.CaseSensitive = false;
            ip.KeepUnmatched = true;
            addParameter(ip, 'PreTime', 0, @isnumeric);
            addParameter(ip, 'StimTime', 0, @isnumeric);
            addParameter(ip, 'TailTime', 0, @isnumeric);
            addParameter(ip, 'BaseIntensity', 0.5, @isnumeric);
            addParameter(ip, 'Contrast', 1, @isnumeric);
            parse(ip, varargin{:});

            obj.preTime = ip.Results.PreTime;
            obj.stimTime = ip.Results.StimTime;
            obj.tailTime = ip.Results.TailTime;
            obj.baseIntensity = ip.Results.BaseIntensity;
            obj.contrast = ip.Results.Contrast;
        end

        function value = get.amplitude(obj)
            value = obj.calculateAmplitude();
        end

        function value = get.totalTime(obj)
            value = obj.calculateTotalTime();
        end

        function value = get.totalSamples(obj)
            value = obj.sec2samples(obj.totalTime);
        end

        function value = get.totalPoints(obj)
            value = obj.sec2pts(obj.totalTime);
        end

        function fName = getFileName(obj) %#ok<MANU> 
            % GETFILENAME
            %
            % Description:
            %   Specifies a default file name. Overwrite in subclasses
            %
            % Syntax:
            %   fName = getFileName(obj)
            % -------------------------------------------------------------
            fName = 'Stimulus';
        end
    end

    methods (Access = protected)
        function value = calculateTotalTime(obj)
            % CALCULATETOTALTIME
            % Can be overwritten by subclasses if needed
            % -------------------------------------------------------------
            value = obj.preTime + obj.stimTime + obj.tailTime;
        end

        function value = calculateAmplitude(obj)
            % CALCULATEAMPLITUDE
            % Can be overwritten by subclasses if needed
            % -------------------------------------------------------------
            if obj.baseIntensity == 0
                value = obj.contrast;
            else
                value = obj.baseIntensity * obj.contrast;
            end
        end
    end

    % Convenience methods
    methods
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

