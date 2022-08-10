classdef Fluorescence < aod.core.responses.RegionResponse
%
% Description:
%   Wrapper for aod.core.responses.RegionResponses
%
% See also:
%   aod.core.responses.RegionResponses()
% -------------------------------------------------------------------------
    methods
        function obj = Fluorescence(parent, varargin)
            obj = obj@aod.core.responses.RegionResponse(parent);
        end

        function load(obj)
            load@aod.core.responses.RegionResponse(obj);
            % Account for the first frame being deleted
            obj.Timing = aod.core.timing.TimeRate(...
                1/obj.Dataset.sampleRate, obj.Timing.Count,... 
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