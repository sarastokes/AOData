classdef ConeInputSNR < aod.core.Analysis 


    properties 
        Amplitudes
        NoiseMean 
        NoiseSD 
        DPrimes
        Annotation
    end

    properties (Hidden, Constant)
        spectralClasses = ["liso", "miso", "siso", "luminance", "control"];
    end

    methods
        function obj = ConeInputSNR(varargin)
            obj@aod.core.Analysis('ConeInputSNR', varargin{:});

            ip = aod.util.InputParser;
            addParameter(ip, 'Annotation', [],... 
                @(x) aod.util.isEntitySubclass(x, 'Annotation'));
            parse(ip, varargin{:});

            % Check for Parent
            if isempty(obj.Parent)
                error('ConeInputSNR:NoParent',...
                    'Optional input "Parent" must be provided');
            end
            
            % Try to extract Annotation, if not provided
            if isempty(ip.Results.Annotation) 
                if isempty(obj.Parent.Annotations)
                    error('ConeInputSNR:NoAnnotation',...
                        'No annotation was found for identifying ROIs');
                else
                    obj.Annotation = obj.Parent.Annotations(1);
                    warning('ConeInputSNR:NoAnnotation',...
                        'Using the first Annotation in Experiment');
                end
            else
                obj.Annotation = ip.Results.Annotation;
            end

            % Extract cone contrasts from calibration, if present
            cal = obj.Parent.get('Calibration',... 
                {'Class', 'sara.calibrations.MaxwellianView'});
            if ~isempty(cal)
                coneContrasts = zeros(1,3);
                coneContrasts(1) = cal.stimPowers.L(1);
                coneContrasts(2) = cal.stimPowers.M(2);
                coneContrasts(3) = cal.stimPowers.S(3);
                obj.setParam('ConeContrasts', coneContrasts);
            end
        end

        function go(obj)
            obj.Amplitudes = []; obj.DPrimes = [];
            obj.NoiseMean = [];  obj.NoiseSD = [];

            for i = 1:numel(obj.spectralClasses)
                [F1amp, noiseMean, noiseSD, dPrime] = obj.calculate(obj.spectralClasses(i));
                obj.Amplitudes = cat(3, obj.Amplitudes, F1amp);
                obj.NoiseMean = cat(3, obj.NoiseMean, noiseMean);
                obj.NoiseSD = cat(3, obj.NoiseSD, noiseSD);
                obj.DPrimes = cat(3, obj.DPrimes, dPrime);
            end
        end
    end

    methods (Access = protected)
        function [F1amp, noiseMean, noiseSD, dPrime] = calculate(obj, whichStim)
            epochs = obj.findEpochsAndStimuli(whichStim);
            fprintf('Beginning analysis of %s\n', whichStim);
            
            % Get the relevant parameters
            sampleRate = obj.getParam('SampleRate');
            highPassCutoff = obj.getParam('HighPass');
            temporalFrequency = obj.getParam('TemporalFrequency');
            noiseWindow = obj.getParam('NoiseFrequencyWindow');

            F1amp = []; dPrime = [];
            noiseMean = []; noiseSD = [];

            for i = 1:numel(epochs)
                % Get epoch fluorescence
                F = epochs(i).get('Response', {'Name', 'TylerF'});
                resp = F.Data;
                if ~isempty(highPassCutoff)
                    resp = signalHighPassFilter(resp', highPassCutoff, sampleRate)';
                end

                for j = 1:size(resp, 2)
                    [p, f] = signalPowerSpectrum(resp(:,j), sampleRate);
                    F1amp(j,i) = p(findclosest(f, temporalFrequency));
                    % Estimate noise from a higher frequencies
                    noise = p(f >= noiseWindow(1) & f <= noiseWindow(2)); 
                    noiseMean(j,i) = mean(noise);
                    noiseSD(j,i) = std(noise);
                end 
            end
            dPrime = (F1amp - noiseMean) ./ noiseSD;
        end

        function epochs = findEpochsAndStimuli(obj, whichStim)
            switch lower(whichStim) 
                case 'siso' 
                    stimuli = obj.Parent.get('Stimulus',... 
                        {'Param', 'spectralClass', sara.SpectralTypes.Siso});
                case 'miso'
                    stimuli = obj.Parent.get('Stimulus',... 
                        {'Param', 'spectralClass', sara.SpectralTypes.Miso});
                case 'liso'
                    stimuli = obj.Parent.get('Stimulus',... 
                        {'Param', 'spectralClass', sara.SpectralTypes.Liso});
                case 'luminance'
                    stimuli = obj.Parent.get('Stimulus',... 
                        {'Dataset', 'protocolName', @(x) contains(x, 'luminance')});
                case 'control'
                    stimuli = obj.Parent.get('Stimulus',... 
                        {'Dataset', 'protocolName', @(x) contains(x, 'control')});
            end

            if isempty(stimuli)
                error('findEpochsAndStimuli:NoMatches',...
                    'No matches were found for %s', whichStim);
            end

            % Assign temporal frequency if user did not assign
            % Note: this cannot be extracted from the control stimulus
            if isempty(obj.getParam('TemporalFrequency'))
                obj.setParam('temporalFrequency', stimuli(1).getParam('temporalFrequency'));
            end

            epochs = getParent(stimuli);
        end
    end

    methods (Access = protected)
        function value = getExpectedParameters(obj)
            value = getExpectedParameters@aod.core.Analysis(obj);

            value.add('SampleRate', 25.3, @isnumeric,...
                'Sample rate for data acquisition, in Hz');
            value.add('HighPass', 0.1, @isnumeric,...
                'Cutoff for optional high pass filtering, in Hz');
            value.add('TemporalFrequency', [], @isnumeric,...
                'Modulation frequency of stimulus, in Hz');
            value.add('NoiseFrequencyWindow', [0.32 1.08], @isnumeric,...
                'Window of temporal frequencies for estimating noise, in Hz');
            value.add('Threshold', 2, @isnumeric,...
                'Responsivity cutoff in SDs');
            value.add('ConeContrasts', [1 1 1],... 
                @(x) isnumeric(x) & numel(x) == 3 & max(x) <= 1,...
                'L, M and S-cone contrasts of L, M and S-cone isolating stimuli (0-1)');
        end
    end
end 