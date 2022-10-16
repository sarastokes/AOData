classdef IsoluminanceBoost < sara.protocols.spectral.Steps 
% ISOLUMINANCEBOOST
%
% Description:
%   Vary the weight of red or green LED for an isoluminance modulation
%
% Parent:
%   sara.protocols.spectral.Steps
%
% Constructor:
%   obj = IsoluminanceBoost(calibration, varargin)
% -------------------------------------------------------------------------
    properties 
        whichLED 
        boost 
    end

    properties (Access = private)
        ledID
    end

    methods 
        function obj = IsoluminanceBoost(calibration, varargin)
            obj = obj@sara.protocols.spectral.Steps(...
                calibration, varargin{:});

            ip = inputParser();
            addParameter(ip, 'WhichLED', 'green',... 
                @(x) ismember(lower(x), {'red', 'green'}));
            addParameter(ip, 'Boost', 0.05, @isnumeric);
            parse(ip, varargin{:});

            obj.boost = ip.Results.Boost;
            obj.whichLED = lower(ip.Results.WhichLED);

            % Overwrites
            obj.spectralClass = sara.SpectralTypes.Isoluminance;

            % Derived properties
            if strcmp(obj.whichLED, 'red')
                obj.ledID = 1;
            else
                obj.ledID = 2;
            end
        end

        function ledValues = mapToStimulator(obj)
            ledValues = mapToStimulator@sara.protocols.spectral.Steps(obj);

            ledValues(obj.ledID, ledValues(obj.ledID,:)>ledValues(obj.ledID,1)) =...
                obj.calibration.stimPowers.Isolum(obj.ledID) + obj.boost; 
            ledValues(obj.ledID, ledValues(obj.ledID,:)<ledValues(obj.ledID,1)) =...
                obj.calibration.stimPowers.Isolum(obj.ledID) - obj.boost;
        end

        function fName = getFileName(obj)
            fName = getFileName@sara.protocols.spectral.Steps();
            idx = numel('isoluminance_');
            fName = [fName(1:idx-1), num2str(100*obj.boost), fName(idx:end)];
        end
    end
end 