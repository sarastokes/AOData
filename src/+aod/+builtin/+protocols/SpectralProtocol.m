classdef (Abstract) SpectralProtocol < aod.builtin.protocols.StimulusProtocol
% SPECTRALPROTOCOL
%
% Description:
%   Spatially-uniform stimuli with multiple LEDs
%
% Properties:
%   spectralClass           patterson.
%   baseIntensity (0-1)     baseline intensity of stimulus
%   contrast (0-1)          scaling applied during stimTime
%                           - computed as contrast if baseIntensity > 0
%                           - computed as intensity if baseIntensity = 0
%
% A stimulus is written by the following logic:
%   1. GENERATE: Calculates normalized stimulus values (0-1)
%   2. MAPTOSTIMULATOR: Uses calibrations to convert to power
%   3. WRITESTIM: Outputs the file used by imaging software
% Each method will call the prior steps
% -------------------------------------------------------------------------

    properties
        spectralClass           aod.builtin.SpectralTypes
    end

    properties (Dependent, Access = protected)
        ledMeans
    end

    properties (SetAccess = protected)
        sampleRate = 25
        stimRate = 500
    end
    

    methods
        function obj = SpectralProtocol(calibration, varargin)
            obj = obj@aod.builtin.protocols.StimulusProtocol(calibration, varargin{:});

            ip = inputParser();
            ip.CaseSensitive = false;
            ip.KeepUnmatched = true;
            addParameter(ip, 'SpectralClass', aod.builtin.SpectralTypes.Luminance,...
                @(x) isa(x, 'aod.builtin.SpectralTypes'));
            parse(ip, varargin{:});

            obj.spectralClass = ip.Results.SpectralClass;
        end

        function value = get.ledMeans(obj)
            if isempty(obj.calibration)
                value = [];
            else
                value = obj.calibration.stimPowers.Background;
            end
        end

        function ledValues = mapToStimulator(obj)
            % MAPTOLEDS
            %
            % Syntax:
            %   ledValues = mapToLeds(obj)
            % -------------------------------------------------------------
            data = obj.generate();
            ledValues = data .* (2*obj.ledMeans)';
        end

        function writeStim(obj, fName)
            % WRITESTIM
            %
            % Syntax:
            %   writeStim(obj, fName)
            % -------------------------------------------------------------
            ledValues = obj.mapToStimulator();
            makeLEDStimulusFile(fName, ledValues);
        end

        function fName = getFileName(obj) %#ok<MANU> 
            % Overwrite in subclasses if needed
            fName = 'SpectralStimulus';
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
            ledValues = obj.mapToLeds();
            ledPlot(ledValues, obj.stim2sec(1:size(ledValues, 2)));
            title(obj.getFileName(), 'Interpreter','none');
            figPos(gcf, 1.5, 1);
            tightfig(gcf);
        end
    end
end