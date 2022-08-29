classdef Mean < aod.core.Response
% MEAN
%
% Description:
%   Takes the average across the full imaging window, over time
%
% Parent:
%   aod.core.Response
%
% Constructor:
%   obj = Mean(parent)
% -------------------------------------------------------------------------

    methods
        function obj = Mean(parent)
            obj = obj@aod.core.Response('Mean');
            obj.setParent(parent);
            obj.load();
        end

        function load(obj)
            imStack = obj.Parent.getStack();
            obj.setData(squeeze(mean(imStack, [1 2], 'omitnan')));

            sampleRate = obj.Experiment.sampleRate;
            obj.setTiming(aod.core.timing.TimeRate(1/sampleRate,... 
                size(imStack,3), 1/sampleRate));
        end

        function plot(obj, varargin)
            ax = axes('Parent', figure());
            plot(ax, obj.Timing.Time, obj.Data, varargin{:});
        end
    end
end