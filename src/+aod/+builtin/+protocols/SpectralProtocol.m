classdef (Abstract) SpectralProtocol < aod.builtin.protocols.StimulusProtocol
% SPECTRALPROTOCOL (abstract)
%
% Description:
%   Spatially-uniform stimuli with multiple LEDs
%
% Syntax:
%   obj = SpectralProtocol(calibration, varargin)
%
% Parent:
%   aod.builtin.protocols.StimulusProtocol
%
% Properties:
%   spectralClass           ao.builtin.SpectralTypes
% Properties inherited from StimulusProtocol
%   preTime                 time before stimulus in seconds
%   stimTime                time during stimulus
%   tailTime                time after stimulus in seconds
%   baseIntensity (0-1)     baseline intensity of stimulus
%   contrast (0-1)          scaling applied during stimTime
%                           - computed as contrast if baseIntensity > 0
%                           - computed as intensity if baseIntensity = 0
%
% A stimulus is written by the following logic:
%   1. GENERATE: Calculates normalized stimulus values (0-1)
%   2. MAPTOSTIMULATOR: Uses calibrations to convert stim (0-1) to power
%   3. WRITESTIM: Outputs the file used by imaging software
% Calling any one of these methods will call each previous step
%
% Public methods for subclasses to overwrite:
%
% Additional public methods:
%   fName = getFileName(obj)    Subclasses overwrite to automate file names
%   ledPlot(obj)                Plots R,G,B LED temporal traces
%
% Inherited methods for subclasses to potentially overwrite:
%   value = calculateTotalTime(obj)
%
% See aod.builtin.protocols.StimulusProtocol and aod.core.Protocol for
% additional inherited methods
%
% TODO: Some 1P-specific implementation here
% -------------------------------------------------------------------------

    properties (Abstract, SetAccess = protected)
        numLEDs
    end

    methods
        function obj = SpectralProtocol(calibration, varargin)
            obj = obj@aod.builtin.protocols.StimulusProtocol(calibration, varargin{:});
        end

        function fName = getFileName(obj) %#ok<MANU> 
            % Overwrite in subclasses if needed
            fName = 'SpectralStimulus';
        end

        function ledValues = mapToStimulator(obj)
            ledValues = obj.generate();
        end

        function ledPlot(obj)
            % LEDPLOT
            %
            % Description:
            %   Plots the powers of each LED
            %
            % Syntax:
            %   ledPlot(obj)
            % -------------------------------------------------------------
            ledValues = obj.mapToStimulator();
            ax = ledPlot(ledValues, obj.pts2sec(1:size(ledValues, 2)));
            title(ax, obj.getFileName(), 'Interpreter','none');
            xlabel(ax, 'Time (sec)');
            ylabel(ax, 'Power (uW)');
            figPos(ax.Parent, 1.5, 1);
            tightfig(ax.Parent);
        end
    end
end