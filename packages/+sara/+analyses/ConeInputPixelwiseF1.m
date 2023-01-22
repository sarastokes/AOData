classdef ConeInputPixelwiseF1 < aod.core.Analysis
% Computes pixelwise cycle-averaged F1 amplitude at modulation frequency 
%
% See also:
%   sara.analyses.ConeInputPixelwiseSNR

% By Sara Patterson, 2023 (sara-aodata-package)
% -------------------------------------------------------------------------
    properties (SetAccess = protected)
        % F1 amplitudes during epochs with l-cone modulation
        lConeF1
        lConeF2
        % F1 phases during epochs with l-cone modulation
        lConeP1
        % F1 amplitudes during epochs with m-cone modulation
        mConeF1
        mConeF2
        % F1 phases during epochs with m-cone modulation
        mConeP1
        % F1 amplitudes during epochs with s-cone modulation
        sConeF1
        sConeF2
        % F1 phases during epochs with s-cone modulation
        sConeP1
        % F1 amplitudes during epochs with luminance modulation
        LumF1
        LumF2
        % F1 phases during epochs with luminance modulation
        LumP1
        % F1 amplitudes during epochs with no modulation (control)
        CtrlF1
        CtrlF2
        % F1 phases during epochs with no modulation (control)
        CtrlP1
    end

    properties (Hidden, Constant)
        spectralClasses = ['liso', 'miso', 'siso', 'luminance', 'control'];
    end

    methods
        function obj = ConeInputPixelwiseF1(varargin)
            obj@aod.core.Analysis('ConeInputPixelwiseF1', varargin{:});
            
            % If parent Epoch has SampleRate parameter set, override
            if obj.Parent.hasParam('SampleRate') ...
                    && ~isempty(obj.Parent.getParam('SampleRate'))
                obj.setParam('SampleRate', obj.Parent.getParam('SampleRate'));
            end
        end

        function go(obj)
            [obj.lConeF1, obj.lConeP1, obj.lConeF2] = obj.calculate('liso');
            [obj.mConeF1, obj.mConeP1, obj.mConeF2] = obj.calculate('miso');
            [obj.sConeF1, obj.sConeP1, obj.sConeF2] = obj.calculate('siso');
            [obj.LumF1, obj.LumP1, obj.LumF2] = obj.calculate('Luminance');
            [obj.CtrlF1, obj.CtrlP1, obj.CtrlF2] = obj.calculate('Control');        
        end
    end

    methods (Access = protected)
        function [epochs, traces] = findEpochsAndStimuli(obj, whichStim)
            switch lower(whichStim) 
                case 'siso' 
                    stimuli = obj.Parent.get('Stimulus',... 
                        {'Param', 'spectralClass', sara.SpectralTypes.Siso});
                    traces = arrayfun(@(x) x.presentation.B, stimuli, ...
                        'UniformOutput', false);
                case 'miso'
                    stimuli = obj.Parent.get('Stimulus',... 
                        {'Param', 'spectralClass', sara.SpectralTypes.Miso});
                    traces = arrayfun(@(x) x.presentation.G, stimuli, ...
                        'UniformOutput', false);
                case 'liso'
                    stimuli = obj.Parent.get('Stimulus',... 
                        {'Param', 'spectralClass', sara.SpectralTypes.Liso});
                    traces = arrayfun(@(x) x.presentation.R, stimuli, ...
                        'UniformOutput', false);
                case 'luminance'
                    stimuli = obj.Parent.get('Stimulus',... 
                        {'Dataset', 'protocolName', @(x) contains(x, 'luminance')});
                    traces = arrayfun(@(x) x.presentation.R, stimuli, ...
                        'UniformOutput', false);
                case 'control'
                    % Control does not have modulations used to extract the
                    % cycle averages. Instead, it's analyzed with the
                    % modulations presented during another stimulus and
                    % provides the estimate of the F1 and F2 amplitudes
                    % which would be obtained by chance when no stimulus is
                    % presented. Get luminance stimulus traces and then get
                    % control stimulus for epoch extraction
                    stimuli = obj.Parent.get('Stimulus',... 
                        {'Dataset', 'protocolName', @(x) contains(x, 'luminance')});
                    traces = arrayfun(@(x) x.presentation.R, stimuli, ...
                        'UniformOutput', false);
                    stimuli = obj.Parent.get('Stimulus',... 
                        {'Dataset', 'protocolName', @(x) contains(x, 'control')});
            end

            if isempty(stimuli)
                error('findEpochsAndStimuli:NoMatches',...
                    'No matches were found for %s', whichStim);
            end

            epochs = getParent(stimuli);
        end

        function [stackF1, stackP1, stackF2] = calculate(obj, whichStim)
            [epochs, traces] = obj.findEpochsAndStimuli(whichStim);
            fprintf('Beginning analysis of %s\n', whichStim);

            
            % Get the relevant parameters
            sampleRate = obj.getParam('SampleRate');
            highPassCutoff = obj.getParam('HighPass');
            
            % Use the first video to determine sizing for preallocation
            imStack = sara.util.loadEpochVideo(epochs(1));
            stackF1 = NaN(size(imStack,1), size(imStack,2), numel(epochs));
            stackP1 = stackF1;
            stackF2 = stackF1;

            for i = 1:numel(epochs)
                tic
                if i > 1
                    imStack = sara.util.loadEpochVideo(epochs(i),...
                        'SmoothEdges', true);
                end

                epd = epochs(i).get('EpochDataset', {'Name', 'ArtifactDetection'});
                if isempty(epd)
                    omitMask = zeros(size(imStack,1), size(imStack,2));
                else
                    omitMask = epd.omissionMask;
                end

                if ~isempty(highPassCutoff)
                    for x = 1:size(imStack,2)
                        for y = 1:size(imStack,1)
                            if omitMask(y, x) == 0
                                imStack(y,x,:) = signalHighPassFilter( ...
                                    squeeze(imStack(y,x,:))', highPassCutoff, sampleRate);
                            end
                        end
                    end
                end

                for x = 1:size(imStack,2)
                    for y = 1:size(imStack,1)
                        if omitMask(y, x) == 0
                            avgCycle = cycleAverageFromStim(squeeze(imStack(y, x, :)), traces{i});
                            [stackF1(y, x, i), stackP1(y, x, i)] = getFourierComponents(avgCycle, 1);
                            [stackF2(y, x, i), ~] = getFourierComponents(avgCycle, 2);
                        end
                    end
                end
                fprintf('Time elapsed %.2f\n', toc);
            end
        end
    end

    methods (Access = protected)
        function value = getExpectedParameters(obj)
            value = getExpectedParameters@aod.core.Analysis(obj);

            value.add('HighPass', 0.1, @isnumeric,...
                'Cutoff for optional highpass filter in Hz');
            value.add('SampleRate', 25.3, @isnumeric,...
                'Sample rate for data acquisition, in Hz');
        end
    end

    % Plotting functions
    methods
        function showRepeatibility(obj, whichStim)
            arguments
                obj
                whichStim           string
            end

            figure('Name', 'Repeatibility');
            for j = 1:numel(whichStim)
                F1name = obj.stim2prop(whichStim(j));
                data = obj.(F1name);
                for i = 1:size(data, 3)
                    subplot(numel(whichStim), size(data,3), i+((j-1)*3));
                    hold on;
                    imagesc(imageSmoothAndScale(data(:,:,i), 1));
                    title(sprintf('%s %u', F1name, i));
                    axis tight equal off
                    colorbar();
                end
            end
            tightfig(gcf);
        end

        function cdata = normalize(obj, whichStim, varargin)
            ip = inputParser();
            ip.CaseSensitive = false;
            addParameter(ip, 'Plot', false, @islogical);
            addParameter(ip, 'Parent', [], @ishandle);
            addParameter(ip, 'Smooth', [], @isnumeric);
            addParameter(ip, 'Method', 'df',... 
                @(x) ismember(lower(x), ["dff", "df", "zscore"]));
            addParameter(ip, 'Threshold', [], @isnumeric);
            parse(ip, varargin{:});
            ax = ip.Results.Parent;
            method = ip.Results.Method;

            F1name = obj.stim2prop(whichStim);
            data = obj.(F1name);
            ctrlData = obj.(obj.stim2prop('ctrl'));

            if ~isempty(ip.Results.Smooth)
                data = imgaussfilt(data, ip.Results.Smooth);
                ctrlData = imgaussfilt(ctrlData, ip.Results.Smooth);
            end

            switch lower(method)
                case 'df' 
                    cdata = nanmean(data, 3) - nanmean(ctrlData, 3);
                case 'dff'
                    cdata = (nanmean(data, 3) - nanmean(ctrlData, 3)) ./ nanmean(ctrlData, 3);
                case 'zscore'
                    cdata = nanmean(data, 3) - nanmean(ctrlData, 3) ./ nanstd(ctrlData, [], 3);
            end
            cdata(isnan(cdata)) = 0;


            if ~isempty(ip.Results.Threshold)
                cdata(abs(cdata) < ip.Results.Threshold) = 0;
            end

            if ip.Results.Plot
                if isempty(ax)
                    ax = axes('Parent', figure());
                end
                imagesc(ax, cdata); hold on;
                %rgbmap('dark red', 'red', 'light red', 'white', ...
                %    'light blue', 'blue', 'dark blue');
                rgbmap('dark red', 'red', 'white', 'blue', 'dark blue')
                axis equal tight off
                makeColormapSymmetric(ax);
                colorbar(ax);
                title(ax, F1name);
                tightfig(ax.Parent);
            end
        end

        function F1map = rgbMap(obj, varargin)
            
            ip = aod.util.InputParser();
            addParameter(ip, 'Plot', false, @islogical);
            parse(ip, varargin{:});

            F1map = [];
            cones = {'liso', 'miso', 'siso'};
            stimContrasts = [0.2476, 0.335, 0.9282];
            scaleFactor = stimContrasts ./ min(stimContrasts);
            for i = 1:3
                iData = obj.normalize(cones{i}, ip.Unmatched);
                % Scale for stimulus contrast
                iData = iData ./ scaleFactor(i);
                F1map = cat(3, F1map, iData);
            end
            F1map(F1map < 0) = 0;
            %assignin('base', 'F1map', F1map);
            %for i = 1:3
            %    iMap = squeeze(F1map(:,:,i));
            %    fprintf('Cutoff %u = %.2f\n', i, prctile(iMap(:), 50));
            %    iMap(iMap < prctile(iMap(:), 80)) = 0;
            %    iMap(iMap > prctile(iMap(:), 99)) = 1;
            %    F1map(:,:,i) = iMap;
            %end
            F1map = F1map ./ max(F1map, [], 1:2);
            %F1map = (F1map-min(F1map(:)) / (max(F1map-min(F1map(:)), [], "all")));
            F1map = (1+F1map) / 2;

            if ip.Results.Plot
                figure('Name', 'RGB Plot');
                image(F1map); hold on;
                title(obj.Parent.Name, 'Interpreter', 'none');
                axis equal tight off;
                tightfig(gcf);
            end
        end
    end

    methods (Static)
        function [F1name, P1name, F2name] = stim2prop(stimName)
            stimName = convertStringsToChars(stimName);
            stimName = lower(stimName);

            if ismember(stimName, {'siso', 'miso', 'liso'})
                F1name = [stimName(1), 'ConeF1'];
                F2name = [stimName(1), 'ConeF2'];
                P1name = [stimName(1), 'ConeP1'];
            elseif startsWith(stimName, 'lum')
                F1name = 'LumF1'; F2name = 'LumF2'; P1name = 'LumP1';
            elseif ismember(stimName, {'ctrl', 'control'})
                F1name = 'CtrlF1'; F2name = 'CtrlF2'; P1name = 'CtrlP1';
            end
        end
    end
end