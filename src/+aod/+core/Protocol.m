classdef (Abstract) Protocol < handle 
% PROTOCOL (abstract)
%
% Syntax:
%   obj = aod.core.Protocol(stimTime, calibration, varargin)
%
% Properties:
%   calibration         aod.core.Calibration (optional)
%   dateCreated         datetime, when the protocol was created (optional)
%
% Dependent properties:
%   totalTime           total stimulus time (from calculateTotalTime)
%   totalSamples        total number of samples in stimulus
%   calibrationDate     date calibration was performed
%
% Abstract properties (must be set by subclasses):
%   sampleRate          the rate data is sampled (hz)
%   stimRate            the rate stimuli are presented (hz)
%
%
% Abstract methods:
%   stim = generate(obj)
%   fName = getFileName(obj)
%   writeStim(obj, fileName)
%
% Methods (to be redefined by subclasses if needed):
%   stim = mapToStimulator(obj)
% -------------------------------------------------------------------------

    properties  
        calibration                 % aod.core.Calibration
        dateCreated                 datetime            = datetime.empty()
    end

    properties (Dependent)
        calibrationDate
    end

    properties (Abstract, SetAccess = protected)
        sampleRate(1,1)             double
        stimRate(1,1)               double
    end

    methods (Abstract)
        stim = generate(obj)
        fName = getFileName(obj)
        writeStim(obj, fName)
    end

    methods
        function obj = Protocol(calibration)
            if nargin > 0 && ~isempty(calibration)
                assert(isSubclass(calibration, 'aod.core.Calibration'),...
                    'Input must be of class aod.core.Calibration');
                obj.calibration = calibration;
            else
                obj.calibration = aod.core.calibrations.Empty();
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
    methods
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
            value = pts/obj.stimRate;
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