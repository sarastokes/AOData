classdef SpectralProtocolFactory < aod.core.Factory

    properties
        calibration
    end

    methods
        function obj = SpectralProtocolFactory(calibration)
            if nargin < 1 || isempty(calibration)
                calibration = aod.core.calibrations.Empty();
            end
            assert(isSubclass(calibration, 'aod.core.Calibration'),...
                'Initial input must be a aod.core.Calibration subclass');
            obj.calibration = calibration;
        end
    end

    methods
        function protocol = get(obj, fileName)
            
            [~, fileName, ~] = fileparts(char(fileName));

            protocol = obj.parseProtocol(fileName);

            % Check for date created
            searchPattern = '_' + digitsPattern() + lettersPattern() + digitsPattern(4);
            dateStr = extract(fileName, searchPattern);
            if ~isempty(dateStr)
                dateStr = char(dateStr);
                protocol.dateCreated = datetime(dateStr(2:end), 'Format', 'yyyyMMdd');
            end

        end
    end

    methods (Access = private)
        function protocol = parseProtocol(obj, fileName)
            import patterson.protocols.spectral.*;

            totalTime = extractFlaggedNumber(fileName, 't');

            % Determine baseIntensity
            baseIntensity = extractFlaggedNumber(fileName, 'p');
            if isempty(baseIntensity)
                baseIntensity = extractFlaggedNumber(fileName, 'p', false);
            end
            if isempty(baseIntensity)
                baseIntensity = 0.5;
            end

            if contains(fileName, 'lights_off')
                protocol = Step(obj.calibration,...
                    'PreTime', 20, 'StimTime', totalTime-preTime, 'TailTime', 0,...
                    'BaseIntensity', baseIntensity, 'Contrast', -1);
                return
            end
            if contains(fileName, 'lights_on')
                protocol = Step(obj.calibration,...
                    'PreTime', 20, 'StimTime', totalTime-preTime, 'TailTime', 0,...
                    'BaseIntensity', 0, 'Contrast', baseIntensity);
                return
            end
        end
    end
            
    
    methods (Static)
        function protocol = create(calibration, fileName)
            obj = patterson.factories.SpectralProtocolFactory(calibration);
            protocol = obj.get(fileName);
        end
    end
end 