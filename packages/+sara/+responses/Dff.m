classdef Dff < aod.builtin.responses.RegionResponse
% DFF
%
% Description:
%   Computes a deltaF/F response for each ROI
%
% Parent:
%   aod.builtin.responses.RegionResponse
%
% Constructor:
%   obj = Dff(parent, varargin)
%   obj = Dff(parent, bkgd, varargin)
%
% Optional input:
%   bkgd            Range of background values (default = obj.guessBkgd)
% Optional key/value inputs:
%   Stim            stimulus (default = [])
%   UseMedian       Use median for bkgd (default = false, mean) 
%   Smooth          Sigma (default = 0, no smoothing)
%   HighPass        Cutoff frequency in Hz (default = 0, no filter)
% ----------------------------------------------------------------------
    methods
        function obj = Dff(parent, varargin)
            obj = obj@aod.builtin.responses.RegionResponse('Dff', varargin{:});
            obj.setParent(parent);
            obj.load(varargin{:});
        end

        function load(obj, varargin)
            % Parse optional inputs
            ip = inputParser();
            ip.CaseSensitive = false;
            ip.KeepUnmatched = true;
            addOptional(ip, 'Baseline', [], @isnumeric);
            addParameter(ip, 'UseMedian', false, @islogical);
            addParameter(ip, 'Smooth', 0, @isnumeric);
            addParameter(ip, 'HighPass', 0, @isnumeric);
            parse(ip, varargin{:});
            
            bkgd = ip.Results.Baseline;
            smoothFac = ip.Results.Smooth;
            highCut = ip.Results.HighPass;
            useMedian = ip.Results.UseMedian;

            if isempty(bkgd)
                bkgd = obj.guessBkgd();
            end
            
            % Check for fluorescence 
            F = obj.Parent.getResponse('sara.responses.Fluorescence');

            % Compute the deltaF/F
            signals = F.Data;
            for i = 1:size(signals,1)               
                if useMedian
                    baseline = median(signals(i, bkgd(1):bkgd(2)));
                else
                    baseline = mean(signals(i, bkgd(1):bkgd(2)));
                end
                signals(i,:) = (signals(i,:) - baseline) / baseline;
            end

            % High pass filter, if necessary            
            if ~isempty(highCut)
                signals = signalHighPassFilter(signals, highCut, obj.Experiment.frameRate);
                signals = signalBaselineCorrect(signals, bkgd); 
            end

            % Smooth, if necessary
            if ~isempty(smoothFac)
                signals = mysmooth2(signals, smoothFac);
            end
                     
            % Add to Response
            obj.setData(signals);
            obj.setTiming(F.Timing);
            obj.setParam(ip.Results);
        end
    end

    methods (Access = protected)
        function value = getExpectedParameters(obj)
            value = getExpectedParameters@aod.builtin.responses.RegionResponse(obj);

            value.add('Baseline', [], @(x) numel(x) == 2 & isnumeric(x),...
                'Start and stop frame for baseline region');
            value.add('UseMedian', false, @islogical,...
                'Whether the mean or the median was used');
            value.add('Smooth', [], @isnumeric,...
                'Sigma used for builtin smooth function, if specified');
            value.add('HighPass', [], @isnumeric,...
                'Cutoff for highpass filter in Hz');
        end
    end

    methods (Access = private)
        function bkgd = guessBkgd(obj)
            if obj.Parent.epochType == sara.EpochTypes.Spatial
                stim = getByClass(obj.Parent.Stimuli, 'aod.builtin.stimuli.SpatialStimulus');
            else
                stim = getByClass(obj.Parent.Stimuli, 'aod.builtin.stimuli.SpectralStimulus');
            end
            if isempty(stim)
                error('Dff/guess did not find stimulus');
            end

            prePts = floor(stim.stimParameters('preTime') * obj.Experiment.sampleRate);
            bkgd = [floor(prePts/4) prePts-10];
        end
    end
end 