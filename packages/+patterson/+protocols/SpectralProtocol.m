classdef (Abstract) SpectralProtocol < aod.builtin.protocols.SpectralProtocol
% SPECTRALPROTOCOL
%
% Description:
%   SpectralProtocol for LED stimuli presented on 1P system
%
% Syntax:
%   obj = SpectralProtocol(calibration, varargin)
%
% Parent:
%   aod.builtin.protocols.SpectralProtocol
%
% Properties:
%   spectralClass           ao.builtin.SpectralTypes
%
% Inherited properties:
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
% Additional public methods:
%   fName = getFileName(obj)    Subclasses overwrite to automate file names
%   ledPlot(obj)                Plots R,G,B LED temporal traces
%
% Inherited methods for subclasses to potentially overwrite:
%   value = calculateTotalTime(obj)
%
% See aod.builtin.protocols.StimulusProtocol and aod.core.Protocol for
%   additional inherited methods
% -------------------------------------------------------------------------

    properties
        spectralClass           aod.builtin.SpectralTypes
    end

    properties (Dependent, Access = protected)
        ledMeans
    end

    properties (SetAccess = protected)
        numLEDs = 3
        sampleRate = 25
        stimRate = 500
    end

    methods
    
        function obj = SpectralProtocol(calibration, varargin)
            obj = obj@aod.builtin.protocols.SpectralProtocol(calibration, varargin{:});

            ip = inputParser();
            ip.CaseSensitive = false;
            ip.KeepUnmatched = true;
            addParameter(ip, 'SpectralClass', aod.builtin.SpectralTypes.Luminance);
            parse(ip, varargin{:});

            obj.spectralClass = aod.builtin.SpectralTypes.init(...
                ip.Results.SpectralClass);
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
            %   ledValues = mapTgoioLeds(obj)
            % -------------------------------------------------------------
            ledValues = mapToStimulator@aod.builtin.protocols.SpectralProtocol();

            import aod.builtin.SpectralTypes;
            if obj.isSpectral
                % Assumes 1st value is background for all LEDs
                ledValues = zeros(3, numel(stim));
                ledList = obj.whichLEDs();
                for i = 1:3
                    if ledList(i)
                        ledValues(i, :) = (2*cal.stimPowers.Background(i)) * data;
                    else
                        ledValues(i, :) = (2*cal.stimPowers.Background(i)) * data(1);
                    end
                end
            elseif obj == SpectralTypes.Luminance
                ledValues = data .* (2*cal.stimPowers.Background');
            elseif obj.isConeIsolating
                ledValues = cal.calcStimulus(obj.getAbbrev(), data);
            end
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
    end
end