classdef Dff < aod.core.responses.RegionResponse
% DFF
%
% Description:
%   Computes a deltaF/F response for each region
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
            obj = obj@aod.core.responses.RegionResponse(parent);
            obj.setData(varargin{:});
        end

        function setData(obj, varargin)
            % Parse optional inputs
            ip = inputParser();
            ip.CaseSensitive = false;
            ip.KeepUnmatched = true;
            addOptional(ip, 'Bkgd', obj.guessBkgd(), @isnumeric);
            addParameter(ip, 'UseMedian', false, @islogical);
            addParameter(ip, 'Smooth', 0, @isnumeric);
            addParameter(ip, 'HighPass', 0, @isnumeric);
            parse(ip, varargin{:});
            
            bkgd = ip.Results.Bkgd;
            smoothFac = ip.Results.Smooth;
            highCut = ip.Results.HighPass;
            useMedian = ip.Results.UseMedian;

            % Check for fluorescence 
            F = obj.Parent.getResponse('patterson.responses.Fluorescence');

            % Compute the deltaF/F
            signals = F.Data.Signals;
            for i = 1:size(signals,2)               
                if useMedian
                    baseline = median(signals(bkgd(1):bkgd(2), i));
                else
                    baseline = mean(signals(bkgd(1):bkgd(2), i));
                end
                signals(:,i) = (signals(:,i) - baseline) / baseline;
            end

            % High pass filter, if necessary            
            if highCut > 0
                signals = signalHighPassFilter(signals', highCut, obj.Dataset.frameRate);
                signals = signalBaselineCorrect(signals, bkgd)'; 
            end

            % Smooth, if necessary
            if smoothFac > 0
                signals = mysmooth2(signals', smoothFac)';
            end
            
            % Create time table 
            obj.Data = timetable(F.Data.Time, signals,...
                'VariableNames', {'Signals'});
            
            % Add to response parameters
            obj.addParameter(ip.Results);
        end
    end

    methods (Access = private)
        function bkgd = guessBkgd(obj)
            if obj.Parent.epochType == patterson.EpochTypes.Spatial
                stim = getByClass(obj.Parent.Stimuli, 'aod.builtin.stimuli.SpatialStimulus');
            else
                stim = getByClass(obj.Parent.Stimuli, 'aod.builtin.stimuli.SpectralStimulus');
            end
            if isempty(stim)
                error('Dff/guess did not find stimulus');
            end

            prePts = floor(stim.stimParameters('preTime') * obj.Dataset.sampleRate);
            bkgd = [floor(prePts/4) prePts-10];
        end
    end
end 