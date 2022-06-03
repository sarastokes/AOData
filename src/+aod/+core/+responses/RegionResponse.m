classdef RegionResponse < aod.core.Response
% REGIONRESPONSE
%
% Description:
%   The average response with each ROI in Regions
%
% Properties
%   Data
%   responseParameters
%   dateModified
% -------------------------------------------------------------------------

    methods
        function obj = RegionResponse(parent)
            obj = obj@aod.core.Response(parent);
            obj.setData();
        end

        function setData(obj)
            [signals, xpts] = roiResponses(obj.Parent.getStack(),... 
                obj.Regions.Map(), [], 'FrameRate', obj.Dataset.sampleRate);
            obj.Data = timetable(seconds(xpts'), signals');
            obj.dateModified = datestr(now);
        end
    end
end