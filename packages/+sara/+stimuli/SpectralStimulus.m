classdef SpectralStimulus < aod.builtin.stimuli.VisualStimulus
% SPECTRALSTIMULUS
%
% Constructor:
%   obj = SpectralStimulus(parent, protocol, presentation)
%
% Properties:
%   presentation
%   voltages
% Inherited properties:
%   stimParameters
%
% Methods:
%   importStimulusFiles(obj)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        presentation
        frameRate
        voltages
    end

    methods
        function obj = SpectralStimulus(protocol)
            obj = obj@aod.builtin.stimuli.VisualStimulus(protocol);
            
        end

        function setFrameRate(obj, frameRate)
            assert(isnumeric(frameRate), 'frameRate must be a number');
            obj.frameRate = frameRate;
        end

        function setPresentation(obj, presentation)
            obj.presentation = presentation;
        end

        function setVoltages(obj, voltages)
            obj.voltages = voltages;
        end

        function loadFrames(obj, fName)
            % Get the LED values during each frame
            % -------------------------------------------------------------
            reader = sara.readers.LedFrameTableReader(fName);
            obj.setPresentation(reader.readFile());
            obj.setFrameRate(reader.frameRate);
        end

        function loadVoltages(obj, fName)
            % IMPORTVOLTAGES
            %
            % Description:
            %   Get the command voltages in LED timing
            % -------------------------------------------------------------
            reader = sara.readers.LedVoltageReader(fName);
            obj.setVoltages(reader.readFile());
        end
    end
end