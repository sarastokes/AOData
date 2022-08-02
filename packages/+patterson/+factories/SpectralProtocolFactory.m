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
                protocol.dateCreated = datetime(dateStr(2:end), 'Format', 'ddMMMuuuu');
            end

        end
    end

    methods (Access = private)
        function protocol = parseProtocol(obj, fileName)
            import patterson.protocols.spectral.*;

            % Determine totalTime
            totalTime = extractFlaggedNumber(fileName, 't');

            % Determine baseIntensity
            baseIntensity = extractFlaggedNumber(fileName, 'p_');
            if isempty(baseIntensity)
                baseIntensity = extractFlaggedNumber(fileName, '_p', true);
            end
            if isempty(baseIntensity)
                baseIntensity = 0.5;
            end

            % Baseline
            if contains(fileName, 'background')
                protocol = Baseline(obj.calibration,...
                    'StimTime', totalTime, 'BaseIntensity', baseIntensity);
                return
            end

            % Lights Off
            if contains(fileName, 'lights_off')
                protocol = Step(obj.calibration,...
                    'PreTime', 20, 'StimTime', totalTime-20, 'TailTime', 0,...
                    'BaseIntensity', baseIntensity, 'Contrast', -1);
                return
            end

            % Lights On
            if contains(fileName, 'lights_on')
                protocol = Step(obj.calibration,...
                    'PreTime', 20, 'StimTime', totalTime-20, 'TailTime', 0,...
                    'BaseIntensity', 0, 'Contrast', baseIntensity);
                return
            end

            % Temporal frequency tuning curves
            if contains(fileName, 'hz')
                hz = extractFlaggedNumber(fileName, 'hz');
                if contains(fileName, 'sawtooth')
                    if contains(fileName, '_on_')
                        polarityClass = 'positive';
                    else
                        polarityClass = 'negative';
                    end
                    protocol = SawtoothModulation(obj.calibration,...
                        'PreTime', 20, 'StimTime', 60, 'TailTime', 40,...
                        'BaseIntensity', baseIntensity,...
                        'TemporalFrequency', temporalFrequency,...
                        'PolarityClass', 'positive');
                    return
                else
                    if contains(fileName, 'sine')
                        modulationClass = 'sine';
                    else
                        modulationClass = 'square';
                    end
                    protocol = TemporalModulation(obj.calibration,...
                        'PreTime', 20, 'StimTime', 60, 'TailTime', 40,...
                        'BaseIntensity', baseIntensity,...
                        'TemporalFrequency', hz,...
                        'ModulationClass', modulationClass);
                    return
                end
            end

            % Chirps
            if contains(fileName, 'chirp')
                if totalTime == 190
                    error('SpectralProtocolFactory: StepChirp not yet implemented');
                end
                protocol = Chirp(obj.calibration,...
                    'PreTime', 20, 'StimTime', 100, 'TailTime', 40,...
                    'BaseIntensity', baseIntensity);
                return
            end

            % Sequences
            if contains(fileName, 'seq')
                intensity = extractFlaggedNumber(fileName, 'm');
                sequenceType = extractCrop(fileName, lettersPattern(), '_seq');

                if contains(sequenceType, 'intensity')
                    error('SpectralProtocolFactory: IntensitySeries not yet implemented!');
                end
                protocol = SpectralSequence(obj.calibration,...
                    'PreTime', 20, 'StimTime', 60, 'PulseTime', 5,...
                    'BaseIntensity', baseIntensity, 'Intensity', intensity,...
                    'Sequence', sequenceType);
                return
            end

            % Increment
            if contains(fileName, {'inc_', 'increment_'})
                intensity = extractFlaggedNumber(fileName, 'm');
                if isempty(intensity)
                    intensity = extractFlaggedNumber(fileName, 'pm', true);
                end

                spectralClass = patterson.SpectralTypes.match(fileName);
                if isempty(spectralClass)
                    spectralClass = patterson.SpectralTypes.Luminance;
                end

                stimTime = extractFlaggedNumber(fileName, 's_');
                if isempty(stimTime)
                    stimTime = 20;
                end

                protocol = Pulse(obj.calibration,...
                    'PreTime', 20, 'StimTime', stimTime, 'TailTime', totalTime-(20+stimTime),...
                    'BaseIntensity', baseIntensity, 'Intensity', intensity,...
                    'SpectralClass', spectralClass);
                return
            end

            error('SpectralProtocolFactory: Did not recognize %s!', fileName);
        end
    end
            
    
    methods (Static)
        function protocol = create(calibration, fileName)
            obj = patterson.factories.SpectralProtocolFactory(calibration);
            protocol = obj.get(fileName);
        end
    end
end 