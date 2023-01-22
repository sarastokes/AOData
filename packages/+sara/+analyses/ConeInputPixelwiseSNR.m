classdef ConeInputPixelwiseSNR < aod.core.Analysis
% Compute d-prime metric for F1 amplitude to sinuosidal modulation
%
% Constructor:
%   obj = sara.analyses.ConeInputPixelwiseSNR(varargin)
%
% Notes:
%   Recreates Tyler Godat's ROI-level analysis for pixels within AOData
%
% See also:
%   sara.analyses.ConeInputPixelwiseF1

% By Sara Patterson, 2023 (sara-aodata-package)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        % d-prime metrics
        lConeSNR
        mConeSNR
        sConeSNR
        LumSNR
        CtrlSNR

        % Amplitudes at modulation frequency
        lConeF1
        mConeF1
        sConeF1
        LumF1
        CtrlF1
        
        % Mean and SD of noise
        lConeNoise
        lConeNoiseSD
        mConeNoise
        mConeNoiseSD
        sConeNoise
        sConeNoiseSD
        LumNoise
        LumNoiseSD
        CtrlNoise
        CtrlNoiseSD
    end

    properties (Hidden, Constant)
        spectralClasses = ['liso', 'miso', 'siso', 'luminance', 'control'];
    end

    methods
        function obj = ConeInputPixelwiseSNR(varargin)
            obj@aod.core.Analysis('PixelwiseConeInputSNR', varargin{:});

            if isempty(obj.Parent)
                error('ConeInputPixelwiseSNR:NoParent',...
                    'Optional input "Parent" must be provided');
            end
            
            % If parent Epoch has SampleRate parameter set, override
            if obj.Parent.hasParam('SampleRate') ...
                    && ~isempty(obj.Parent.getParam('SampleRate'))
                obj.setParam('SampleRate', obj.Parent.getParam('SampleRate'));
            end

            % Extract cone contrasts from calibration
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
            [obj.lConeF1, obj.lConeNoise, obj.lConeNoiseSD, obj.lConeSNR] = obj.calculate('liso');
            [obj.mConeF1, obj.mConeNoise, obj.mConeNoiseSD, obj.mConeSNR] = obj.calculate('miso');
            [obj.sConeF1, obj.sConeNoise, obj.sConeNoiseSD, obj.sConeSNR] = obj.calculate('siso');
            [obj.LumF1, obj.LumNoise, obj.LumNoiseSD, obj.LumSNR] = obj.calculate('Luminance');
        end
    end

    
    methods
        function snrMap = rgbMap(obj, varargin)
            ip = aod.util.InputParser();
            addParameter(ip, 'Plot', false, @islogical);
            addParameter(ip, 'UseThreshold', true, @islogical);
            addParameter(ip, 'GrayBkgd', true, @islogical);
            parse(ip, varargin{:});
            plotFlag = ip.Results.Plot;
            if ip.Results.UseThreshold
                threshold = obj.getParam('Threshold');
            else
                threshold = [];
            end

            % Get data and scale by cone contrast of stimulus
            snrMap = [];
            cones = {'liso', 'miso', 'siso'};
            coneContrasts = obj.getParam('ConeContrasts');
            contrastScaler = coneContrasts ./ min(coneContrasts);
            for i = 1:3
                iData = obj.normalize(cones{i}, ip.Unmatched);
                % Threshold using "true" SD before changing the scaling
                if ~isempty(threshold)
                    iData(iData < threshold) = 0;
                end
                iData = iData ./ contrastScaler(i);
                snrMap = cat(3, snrMap, iData);
            end
            
            if plotFlag 
                % Data must scale to 0-255 or 0-1
                snrMap = snrMap / max(abs(snrMap(:)));
                snrMap(snrMap < 0) = 0;
                % Gray background makes colors clearer
                if ip.Results.GrayBkgd
                    snrMap = (1+snrMap) / 2;
                end

                figure('Name', 'RGB Plot');
                image(snrMap); hold on;
                title(obj.Parent.Name, 'Interpreter', 'none');
                axis equal tight off;
                tightfig(gcf);
            end
        end

        function cdata = normalize(obj, whichStim, varargin)
            
            ip = aod.util.InputParser();
            addParameter(ip, 'Plot', false, @islogical);
            addParameter(ip, 'Parent', [], @ishandle);
            addParameter(ip, 'Smooth', [], @isnumeric);
            addParameter(ip, 'OmitNan', false, @islogical);
            parse(ip, varargin{:});

            omitNan = ip.Results.OmitNan;
            ax = ip.Results.Parent;
            plotFlag = ip.Results.Plot;
            smoothFactor = ip.Results.Smooth;

            snrName = obj.stim2prop(whichStim);
            data = obj.(snrName);

            if omitNan
                cdata = mean(data, 3, 'omitnan');
            else
                cdata = mean(data, 3);
            end

            cdata(isnan(cdata)) = 0;

            % TODO: Before or after threshold? Scaling should help
            if ip.Results.Smooth
                cdata = imageSmoothAndScale(cdata, smoothFactor);
            end
            
            % Threshold (cutoff in SDs)
            % threshold = obj.getParam('Threshold');
            % cdata(cdata < threshold) = 0;

            if plotFlag
                if isempty(ax) 
                    ax = axes('Parent', figure());
                end
                imagesc(ax, cdata);
                hold(ax, 'on');
                rgbmap('dark red', 'red', 'white', 'blue', 'dark blue')
                axis equal tight off
                makeColormapSymmetric(ax);
                colorbar(ax);
                title(ax, sprintf('%s %s', obj.Parent.Name, snrName),...
                    'Interpreter', 'none');
                tightfig(ax.Parent);
            end
        end 
    end

    methods (Access = protected)
        function [stackF1, stackNoise, stackNoiseSD, dPrime] = calculate(obj, whichStim)

            % Get the epochs to analyze
            epochs = obj.findEpochsAndStimuli(whichStim);
            fprintf('Beginning analysis of %s\n', whichStim);

            % Get the relevant parameters
            sampleRate = obj.getParam('SampleRate');
            highPassCutoff = obj.getParam('HighPass');
            temporalFrequency = obj.getParam('TemporalFrequency');
            noiseWindow = obj.getParam('NoiseFrequencyWindow');

            % Use the first video to determine sizing for preallocation
            imStack = sara.util.loadEpochVideo(epochs(1));
            stackF1 = NaN(size(imStack,1), size(imStack,2), numel(epochs));
            stackNoise = stackF1;
            stackNoiseSD = stackF1;

            for i = 1:numel(epochs)
                tic  % Track per epoch timing
                % Check for an omission mask
                epd = epochs(i).get('EpochDataset', {'Name', 'ArtifactDetection'});
                if ~isempty(epd)
                    omitMask = epd.omissionMask;
                else
                    omitMask = zeros(size(imStack,1), size(imStack,2));
                end

                if i > 1
                    imStack = sara.util.loadEpochVideo(epochs(i));
                end

                for x = 1:size(imStack, 2)
                    for y = 1:size(imStack, 1)
                        if omitMask(y, x) == 0
                            pixelData = squeeze(imStack(y, x, :))';  % Row
                            if ~isempty(highPassCutoff)
                                pixelData = signalHighPassFilter(pixelData, highPassCutoff, sampleRate);
                            end
                            [p, f] = signalPowerSpectrum(pixelData, sampleRate);
                            stackF1(y,x,i) = p(findclosest(f, temporalFrequency));
                            % Estimate noise from a higher frequencies
                            noise = p(f >= noiseWindow(1) & f <= noiseWindow(2)); 
                            stackNoise(y,x,i) = mean(noise);
                            stackNoiseSD(y,x,i) = std(noise);
                        end
                    end
                end
                fprintf('Time elapsed %.2f\n', toc);
            end
            dPrime = (stackF1 - stackNoise) ./ stackNoiseSD;
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

            % Assign temporal frequency if user did not assign
            % Note this cannot be extracted from the control stimulus
            if isempty(obj.getParam('TemporalFrequency'))
                obj.setParam('temporalFrequency', stimuli(1).getParam('temporalFrequency'));
            end

            if isempty(stimuli)
                error('findEpochsAndStimuli:NoMatches',...
                    'No matches were found for %s', whichStim);
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

    methods (Static)
        function [snrName, F1name, noiseName, sdName] = stim2prop(stimName)
            stimName = convertStringsToChars(stimName);
            stimName = lower(stimName);

            if ismember(stimName, {'liso', 'miso', 'siso'})
                snrName = [stimName(1), 'ConeSNR'];
                F1name = [stimName(1), 'ConeF1'];
                noiseName = [stimName(1), 'ConeNoise'];
                sdName = [stimName(1), 'ConeNoiseSD'];
            elseif startsWith(stimName, 'lum')
                F1name = 'LumF1'; snrName = 'LumSNR';
                noiseName = 'LumNoise'; sdName = 'LumNoiseSD';
            end
        end
    end
end 