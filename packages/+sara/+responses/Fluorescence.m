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
%   obj = Fluorescence(parent, varargin)
% -------------------------------------------------------------------------
    methods
        function obj = Fluorescence(parent, varargin)
            obj = obj@aod.builtin.responses.RegionResponse(parent);
        end

        function load(obj)
            load@aod.builtin.responses.RegionResponse(obj);
            % Account for the first frame being deleted
            obj.Timing = aod.core.timing.TimeRate(...
                1/obj.Experiment.sampleRate, obj.Timing.Count,... 
                obj.Timing.Start+obj.Timing.Interval);
            % obj.Data.Time = obj.Data.Time + obj.Data.Time(1);
        end
    end

    methods (Access = protected)
        function value = getLabel(obj)
            value = sprintf('Epoch%u_Fluorescence', obj.Parent.ID);
        end
    end
end 