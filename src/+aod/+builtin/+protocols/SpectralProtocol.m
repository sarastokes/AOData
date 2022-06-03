classdef (Abstract) SpectralProtocol < aod.core.Protocol
% SPECTRALPROTOCOL
%
% Description:
%   Spatially-uniform stimuli with multiple LEDs
%
% Properties:
%   baseIntensity (0-1)     baseline intensity of stimulus
%   contrast (0-1)          scaling applied during stimTime
%                           - computed as contrast if baseIntensity > 0
%                           - computed as intensity if baseIntensity = 0
%
% A stimulus is written by the following logic:
%   1. GENERATE: Calculates normalized stimulus values (0-1)
%   2. MAPTOLEDS: Uses calibrations to convert to power
%   3. WRITESTIM: Outputs the file used by imaging software
% Each method will call the prior steps
% -------------------------------------------------------------------------

    properties
        ledMeans
        baseIntensity
        contrast    
    end

    properties (Dependent, Access = protected)
        amplitude
        ledRange
    end

    methods
        function obj = SpectralProtocol(ledMeans, varargin)
            obj = obj@aod.core.Protocol(varargin{:});
            obj.ledMeans = ledMeans;

            % Shared by all spectral stimuli
            obj.sampleRate = 25;
            obj.stimRate = 500;

            % Input parsing
            ip = inputParser();
            ip.CaseSensitive = false;
            ip.KeepUnmatched = true;
            addParameter(ip, 'BaseIntensity', 0, @isnumeric);
            addParameter(ip, 'Contrast', 1, @isnumeric);
            parse(ip, varargin{:});

            obj.baseIntensity = ip.Results.BaseIntensity;
            obj.contrast = ip.Results.Contrast;
        end

        function value = get.amplitude(obj)
            if obj.baseIntensity == 0
                value = obj.contrast;
            else
                value = obj.contrast * obj.baseIntensity;
            end
        end

        function value = get.ledRange(obj)
            value = 2 * obj.ledMeans;
        end

        function ledValues = mapToLeds(obj)
            % MAPTOLEDS
            %
            % Syntax:
            %   ledValues = mapToLeds(obj)
            % -------------------------------------------------------------
            data = obj.generate();
            ledValues = data .* obj.ledRange';
        end

        function writeStim(obj, fName)
            % WRITESTIM
            %
            % Syntax:
            %   writeStim(obj, fName)
            % -------------------------------------------------------------
            ledValues = obj.mapToLeds();
            makeLEDStimulusFile(fName, ledValues);
        end

        function fName = getFileName(obj) %#ok<MANU> 
            % Overwrite in subclasses if needed
            fName = 'SpectralStimulus';
        end

        function ledPlot(obj)
            % LEDPLOT
            %
            % Syntax:
            %   ledPlot(obj)
            % -------------------------------------------------------------
            ledValues = obj.mapToLeds();
            ledPlot(ledValues, obj.led2sec(1:size(ledValues, 2)));
            title(obj.getFileName(), 'Interpreter','none');
            figPos(gcf, 1.5, 1);
            tightfig(gcf);
        end
    end
end