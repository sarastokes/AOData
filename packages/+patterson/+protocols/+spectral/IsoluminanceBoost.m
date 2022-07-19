classdef IsoluminanceBoost < patterson.protocols.spectral.Steps 

    properties 
        whichLED 
        boost 
    end

    properties (Access = private)
        ledID
    end

    methods 
        function obj = IsoluminanceBoost(calibration, varargin)
            obj = obj@patterson.protocols.spectralStep(...
                calibration, varargin{:});

            ip = inputParser();
            addParameter(ip, 'WhichLED', 'green',... 
                @(x) ismember(lower(x), {'red', 'green'}));
            addParameter(ip, 'Boost', 0.05, @isnumeric);
            parse(ip, varargin{:});

            obj.boost = ip.Results.Boost;
            obj.whichLED = lower(ip.Results.WhichLED);

            % Overwrites
            obj.spectralClass = patterson.SpectralTypes.Isoluminance;

            % Derived properties
            if strcmp(obj.whichLED, 'red')
                obj.ledID = 1;
            else
                obj.ledID = 2;
            end
        end

        function ledValues = mapToStimulator(obj)
            ledValues = mapToStimulator@patterson.protocols.spectral.Steps(obj);

            ledValues(obj.ledID, ledValues(obj.ledID,:)>ledValues(obj.ledID,1)) =...
                obj.calibration.stimPowers.Isolum(obj.ledID) + obj.boost; 
            ledValues(obj.ledID, ledValues(obj.ledID,:)<ledValues(obj.ledID,1)) =...
                obj.calibration.stimPowers.Isolum(obj.ledID) - obj.boost;
        end

        function fName = getFileName(obj)
            fName = getFileName@patterson.protocols.spectral.Steps();
            idx = numel('isoluminance_');
            fName = [fName(1:idx-1), num2str(100*obj.boost), fName(idx:end)];
        end
    end
end 