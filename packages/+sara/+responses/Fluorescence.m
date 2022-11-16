classdef Fluorescence < aod.builtin.responses.RegionResponse
% FLUORESCENCE
%
% Description:
%   Wrapper for RegionResponses for fluorescence imaging
%
% Parent:
%   aod.builtin.responses.RegionResponses
%
% Constructor:
%   obj = Fluorescence(parent, segmentation, varargin)
% -------------------------------------------------------------------------

    methods
        function obj = Fluorescence(parent, segmentation, varargin)
            obj = obj@aod.builtin.responses.RegionResponse(...
                'Fluorescence', parent, segmentation, varargin{:});
        end

        function load(obj)
            load@aod.builtin.responses.RegionResponse(obj);
            obj.setTiming(aod.core.timing.TimeRate(...
                1/obj.Experiment.sampleRate, obj.Timing.Count,... 
                obj.Timing.Start+obj.Timing.Interval));
        end
    end

    methods (Access = protected)
        function value = getLabel(obj)
            value = sprintf('Epoch%u_Fluorescence', obj.Parent.ID);
        end
    end
end 