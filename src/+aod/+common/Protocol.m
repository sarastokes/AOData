classdef (Abstract) Protocol < handle 
% A protocol detailing experimental design
%
% Description:
%   A Protocol can detail how some aspect of an experiment was designed.
%   For example, determining the LED values for a visual stimulus or laser
%   modulations for optogenetic stimulation. Protocol differs from Stimulus
%   in that Stimulus describes what actually happened during the experiment
%   (e.g. the LED voltages at each frame), while Protocol details the
%   design and commands that define the commands sent to the system for the
%   Stimulus. Also, Protocol is not limited to Stimuli and could also
%   detail, for example, scanner control or any other aspect of the
%   experiment which can be controlled and altered by the experimenter.
%
% Syntax:
%   obj = aod.core.Protocol(stimTime, calibration, varargin)
%
% Properties:
%   calibration         aod.core.Calibration (optional)
%   DateCreated         datetime, when the protocol was created
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

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties  
        Calibration                         = aod.core.Calibration.empty()
        dateCreated     datetime            = datetime.empty()
    end

    properties (Abstract, SetAccess = protected)
        sampleRate (1,1)     double
        stimRate (1,1)       double
    end

    % Abstract methods must be defined by subclasses (see ProtocolTemplate)
    methods (Abstract)
        stim = generate(obj)
        fName = getFileName(obj)
        writeStim(obj, fName)
    end

    methods
        function obj = Protocol(calibration)
            if nargin > 0 && ~isempty(calibration)
                obj.Calibration = calibration;
            else
                obj.Calibration = aod.core.Calibration.empty();
            end

            obj.dateCreated = getDateYMD();
        end

        function setCalibration(obj, calibration)
            % Set the Calibration
            %
            % Notes:
            %   Argument validation handled by property definition
            % -------------------------------------------------------------
            aod.util.mustBeEntityType(calibration, 'Calibration');
            % if ~aod.util.isEntitySubclass(calibration, 'calibration')
            %    error('setCalibration:InvalidInput',...
            %        'Protocol calibration must be of entity type Calibration');
            %end
            obj.Calibration = calibration;
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

        function value = samples2pts(obj, samples)
            % Convert samples to stim points
            %
            % Syntax:
            %   value = samples2sec(obj, samples)
            % -------------------------------------------------------------
            value = floor(samples/obj.sampleRate * obj.stimRate);
        end
    end

    % Overwritten builtin methods
    methods
        function tf = isequal(obj, protocol)
            % Determine whether two protocols are equal
            if ~strcmp(class(protocol), class(obj))
                tf = false; 
                return
            end

            if ~isequal(obj.Calibration, protocol.Calibration)
                tf = false; 
                return
            end

            mc = metaclass(obj);
            for i = 1:numel(mc.PropertyList)
                propName = mc.PropertyList(i).Name;
                % Skip Calibration and properties without public access
                if ~strcmp(mc.PropertyList(i).GetAccess, 'public') || strcmp(propName, 'Calibration')
                    continue
                end
                if isdatetime(obj.(propName)) 
                    if isDateEqual(obj.(propName), protocol.(propName))
                        continue 
                    else
                        tf = false; return
                    end
                end
                if ~isequal(obj.(propName), protocol.(propName))
                    tf = false; return
                end
            end
            % If code runs to this point, the two protocols are equal
            tf = true;
        end
    end
end 