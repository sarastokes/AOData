classdef (Abstract) Protocol < handle 
% PROTOCOL
%
% Syntax:
%   obj = aod.core.Protocol(stimTime, calibration, varargin)
%
% Properties:
%   calibration     aod.core.Calibration (optional)
%
% Abstract properties (must be set by subclasses):
%   sampleRate      the rate data is sampled (hz)
%   stimRate        the rate stimuli are presented (hz)
%
% Dependent properties:
%   totalTime       total stimulus time (from calculateTotalTime)
%   totalSamples    total number of samples in stimulus
%   calibrationDate date calibration was performed
%
% Abstract methods:
%   stim = generate(obj)
%   fName = getFileName(obj)
%   writeStim(obj, fileName)
% Methods (to be subclassed):
%   stim = mapToStimulator(obj)
% -------------------------------------------------------------------------

    properties  
        calibration

    end

    properties (Dependent)
        calibrationDate
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
        function obj = Protocol(calibration)
            if nargin > 0
                assert(isSubclass(calibration, 'aod.core.Calibration'),...
                    'Input must be of class aod.core.Calibration');
                obj.calibration = calibration;
            end
        end

        function value = get.calibrationDate(obj)
            if isempty(obj.calibration)
                value = '';
            else
                value = obj.calibration.calibrationDate;
            end
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
    end
end 