classdef SpectralStimulus < aod.builtin.stimuli.VisualStimulus
    % SPECTRALSTIMULUS
    %
    % Constructor:
    %   obj = SpectralStimulus(parent, protocol, presentation)
    %
    % Properties:
    %   presentation
    % Inherited properties:
    %   stimParameters
    %
    % Methods:
    %   setPresentation(obj, presentation)
    % Inherited methods:
    %   addParameter(obj, varargin)
    % ---------------------------------------------------------------------

    properties (SetAccess = private)
        presentation
        voltages
    end

    methods
        function obj = SpectralStimulus(parent, protocol)
            if nargin < 1
                parent = [];
            end
            obj = obj@aod.builtin.stimuli.VisualStimulus(parent, protocol);
            if isSubclass(obj.Parent, 'aod.core.Epoch')
                obj.importLedFiles();
            end
        end
    end

    methods (Access = private)
        function importLedFiles(obj)
            % IMPORTLEDFILES
            %
            % Syntax:
            %   obj.setPresentation(presentation)
            % -------------------------------------------------------------
            
            % Get the LED values during each sample
            reader = aod.builtin.readers.LedFrameTableReader(...
                obj.Parent.getFilePath('FrameReport'));
            obj.presentation = reader.read();

            % Get the command voltages in LED timing
            reader = aod.builtin.readers.LedVoltageReader(...
                obj.Parent.getFilePath('LedVoltages'));
            obj.voltages = reader.read();
        end
    end
end