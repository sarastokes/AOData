classdef SpectralProtocolFactory < aod.util.Factory

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
            import sara.protocols.spectral.*;

            % Determine totalTime
            totalTime = extractFlaggedNumber(fileName, 't');
            
            % Determine spectralClass
            spectralClass = sara.SpectralTypes.match(fileName);
            if isempty(spectralClass)
                spectralClass = sara.SpectralTypes.Luminance;
            end

            % Determine baseIntensity
            baseIntensity = extractFlaggedNumber(fileName, 'p_');
            if isempty(baseIntensity)
                baseIntensity = extractFlaggedNumber(fileName, '_p', true);
            end
            if isempty(baseIntensity)
                baseIntensity = 0.5;
            else
                baseIntensity = baseIntensity / 100;
            end

            % Baseline
            if contains(fileName, {'background', 'baseline'})
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

            % Steps
            if contains(fileName, 'square') && ~contains(fileName, 'hz')
                contrast = extractFlaggedNumber(fileName, 'c_');
                stepTime = extractFlaggedNumber(fileName, 's_');
                numSteps = extractFlaggedNumber(fileName, 'n_');
                if isempty(numSteps)
                    numSteps = 5;
                end
                
                protocol = Steps(obj.calibration,...
                    'PreTime', 20, 'StepTime', stepTime, 'TailTime', 40,... 
                    'NumSteps', numSteps, 'SpectralClass', spectralClass,...
                    'BaseIntensity', baseIntensity, 'Contrast', contrast);
                return
            end

            % Tyler's protocols
            protocol = obj.checkTylerProtocols(fileName);
            if ~isempty(protocol)
                return
            end

            % Temporal frequency tuning curves
            if contains(fileName, 'hz')
                contrast = extractFlaggedNumber(fileName, 'c_');
                if isempty(contrast)
                    contrast = 1;
                else
                    contrast = contrast / 100;
                end
                hz = extractFlaggedNumber(fileName, 'hz');
                switch totalTime
                    case 110
                        stimTime = 60; tailTime = 30;
                    case 120
                        stimTime = 60; tailTime = 40;
                    case 160
                        stimTime = 100; tailTime = 40;
                    otherwise
                        error('%s total time unrecognized', fileName);
                end
                
                if contains(fileName, 'sawtooth')
                    if contains(fileName, '_on_')
                        polarityClass = 'positive';
                    else
                        polarityClass = 'negative';
                    end
                    protocol = SawtoothModulation(obj.calibration,...
                        'PreTime', 20, 'StimTime', stimTime, 'TailTime', tailTime,...
                        'BaseIntensity', baseIntensity, 'Contrast', contrast,...
                        'TemporalFrequency', hz,...
                        'PolarityClass', polarityClass);
                    return
                else
                    if contains(fileName, 'sine')
                        modulationClass = 'sine';
                    else
                        modulationClass = 'square';
                    end
                    protocol = TemporalModulation(obj.calibration,...
                        'PreTime', 20, 'StimTime', stimTime, 'TailTime', tailTime,...
                        'BaseIntensity', baseIntensity, 'Contrast', contrast,...
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
                    spectralClass = extractCrop(fileName, lettersPattern(), '_intensity');
                    spectralClass = sara.SpectralTypes.init(spectralClass);

                    intensities = extractCrop(fileName, digitsPattern(), 'i_');
                    intensities = cellfun(@str2double, intensities);

                    stepTime = str2double(extractCrop(fileName, digitsPattern(), 's_'));
                    protocol = IntensitySequence(obj.calibration,...
                        'PreTime', 20, 'StepTime', stepTime, 'TailTime', x,...
                        'Intensity', intensities, 'BaseIntensity', baseIntensity,...
                        'SpectralClass', spectralClass);
                    return
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

                spectralClass = sara.SpectralTypes.match(fileName);
                if isempty(spectralClass)
                    spectralClass = sara.SpectralTypes.Luminance;
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

        function protocol = checkTylerProtocols(obj, fileName)

            % Tyler's protocols
            if strcmpi(fileName, 'control_nd1.0')
                protocol = tyler.protocols.spectral.Sinewave(obj.calibration,...
                    'Control', true);
                return
            end

            if contains(fileName, '_0.15hz_nd1.0')
                switch fileName(1:3)
                    case 'l_i'
                        spectralClass = sara.SpectralTypes.Liso;
                    case 'm_i'
                        spectralClass = sara.SpectralTypes.Miso;
                    case 's_i'
                        spectralClass = sara.SpectralTypes.Siso;
                    case 'lum'
                        spectralClass = sara.SpectralTypes.Luminance;
                end
                
                protocol = tyler.protocols.spectral.Sinewave(obj.calibration,...
                    'SpectralClass', spectralClass, 'Control', false);
                return 
            end
            protocol = [];
        end
    end
            
    
    methods (Static)
        function protocol = create(calibration, fileName)
            obj = sara.factories.SpectralProtocolFactory(calibration);
            protocol = obj.get(fileName);
            fprintf('\t%s <-- %s\n', class(protocol), fileName);
        end
    end
end 