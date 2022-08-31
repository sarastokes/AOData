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
        Calibration     aod.core.Calibration    = aod.core.Calibration.empty()
        dateCreated     datetime                = datetime.empty()
    end

    properties (Abstract, SetAccess = protected)
        sampleRate(1,1)     double
        stimRate(1,1)       double
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
                obj.Calibration = calibration;
            end
        end
    end

    methods
        function stim = mapToStimulator(obj)
            % MAPTOSTIMULATOR
            % Should be overwritten by subclasses if needed
            % -------------------------------------------------------------
            stim = obj.generate();
        end
    end

    % Convenience methods
    methods
        function value = sec2pts(obj, t)
            % SEC2PTS
            %
            % Description:
            %   Convert from seconds to stimulus presentations
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
            % Description:
            %   Convert from seconds to samples (data acquisitions)
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