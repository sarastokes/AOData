classdef BackgroundEpoch < sara.Epoch
% BACKGROUNDEPOCH
%
% Description:
%   An epoch measuring the background noise without stimuli
%
% Parent:
%   sara.Epoch
%
% Constructor:
%   obj = BackgroundEpoch(parent, ID, source)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        meanValue
        stdValue
    end

    methods
        function obj = BackgroundEpoch(parent, ID, varargin)
            obj@sara.Epoch(parent, ID, sara.EpochTypes.Background, varargin{:});
        end
    end

    methods
        function getStatistics(obj)
            imStack = obj.getStack();
            obj.meanValue = mean(imStack(:), 'omitnan');
            obj.stdValue = std(imStack(:), 'omitnan');
        end

        function R = getMean(obj)
            R = obj.getResponse('aod.builtin.responses.Mean');
        end
    end
end