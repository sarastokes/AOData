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
    % ---------------------------------------------------------------------

    properties (SetAccess = private)
        presentation
        frameRate
        voltages
    end

    methods
        function obj = SpectralStimulus(parent, protocol)
            if nargin < 1
                parent = [];
            end
            obj = obj@aod.builtin.stimuli.VisualStimulus(parent, protocol);
            if isSubclass(obj.Parent, 'aod.core.Epoch')
                obj.importStimulusFiles();
            end
        end
    end

    methods (Access = private)
        function importStimulusFiles(obj)
            % IMPORTLEDFILES
            %
            % Syntax:
            %   obj.setPresentation(presentation)
            % -------------------------------------------------------------
            
            % Get the LED values during each sample
            reader = aod.builtin.readers.LedFrameTableReader(...
                obj.Parent.getFilePath('FrameReport'));
            obj.presentation = reader.read();
            obj.frameRate = reader.frameRate;

            % Get the command voltages in LED timing
            reader = aod.builtin.readers.LedVoltageReader(...
                obj.Parent.getFilePath('LedVoltages'));
            obj.voltages = reader.read();
        end
    end
end