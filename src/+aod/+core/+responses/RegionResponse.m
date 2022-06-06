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
            if isSubclass(obj.Parent, 'aod.core.Epoch')
                obj.setData();
                % Listen for changes to ROIs and flag for update
                obj.listeners = addlistener(obj.Regions, 'UpdatedRois', @obj.onUpdatedRois);
            end
        end

        function value = get.Regions(obj)
            value = obj.Dataset.Regions;
        end
    end

    methods
        function signals = getData(obj, IDs) 
            % GETDATA
            %
            % Description:
            %   Convenience method for easy access of data
            %
            % Syntax:
            %   Returns just the signals in the timetable
            % 
            % Optional input:
            %   IDs         integers
            %       Specific columns (ROIs) to return (default returns all)
            % Output:
            %   signals     double [time x rois]
            % -------------------------------------------------------------
            if isempty(obj.Data)
                error('Data has not been set!');
            end
            signals = obj.Data.Signals;
            if nargin == 2
                signals = signals(:, IDs);
            end
        end

        function setData(obj)
            % SETDATA
            %
            % Description:
            %   Get the average response over all pixels in ROI
            % -------------------------------------------------------------
            roiMask = double(obj.Regions.Map);
            sampleRate = obj.Dataset.sampleRate;
            imStack = obj.Parent.getStack();
            roiList = obj.Regions.roiIDs;
        
            A = [];
            for i = 1:obj.Regions.Count
                [a, b] = find(roiMask == roiList(i));
                % Look for ROIs exceeding image size
                a(b > size(imStack,2)) = [];
                b(b > size(imStack,2)) = [];
                b(a > size(imStack,1)) = [];
                a(a > size(imStack,1)) = [];
                % Time course for each pixel in the ROI
                signal = zeros(numel(a), size(imStack, 3));
                for j = 1:numel(a)
                    signal(j, :) = squeeze(imStack(a(j), b(j), :));
                end
                % Average timecourse over all pixels in the ROI
                signal = mean(signal);
                % Append to the matrix
                A = cat(1, A, signal);
            end

            xpts = 1/sampleRate : 1/sampleRate : (size(imStack,3))/sampleRate;
            obj.Data = timetable(seconds(xpts'), A',...
                'VariableNames', {'Signals'});
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