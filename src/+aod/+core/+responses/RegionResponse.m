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
% Dependent properties:
%   Dataset
%   Regions
% Private properties
%   listeners
% -------------------------------------------------------------------------

    properties (Access = private)
        listeners
    end

    properties (Dependent) 
        Regions
    end

    methods
        function obj = RegionResponse(parent)
            obj = obj@aod.core.Response(parent);
            obj.setData();

            % Listen for changes to ROIs and flag for update
            obj.listeners = addlistener(obj.Regions, 'UpdatedRois', @obj.onUpdatedRois);
        end

        function value = get.Regions(obj)
            value = obj.Dataset.Regions;
        end
    end

    methods
        function setData(obj)
            [signals, xpts] = roiResponses(obj.Parent.getStack(),... 
                obj.Regions.Map(), [], 'FrameRate', obj.Dataset.sampleRate);
            obj.Data = timetable(seconds(xpts'), signals',... 
                'VariableNames', {'Signals'});
            obj.dateModified = datestr(now);
        end

        function [signals, xpts] = getRoiResponse(obj, ID)
            if isempty(obj.Responses)
                obj.setData();
            end
            ID = obj.Regions.parseRoi(ID);

            signals = obj.Data.Signals(:, ID)';
            xpts = obj.Data.Time';
        end
    end

    methods (Access = protected)
        function value = getDisplayName(obj)
            value = sprintf('Epoch%u_Responses', obj.Parent.ID);
        end
    end

    methods (Access = private)
        function onUpdatedRois(obj, ~, ~)
            obj.setData();
        end
    end
end