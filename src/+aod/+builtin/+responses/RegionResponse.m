classdef RegionResponse < aod.core.Response
% REGIONRESPONSE
%
% Description:
%   The average response with each region of a annotation
%
% Parent:
%   aod.core.Response
%
% Constructor:
%   obj = RegionResponse(name, parent, annotation, varargin)
%
% Properties:
%   Annotation          aod.core.Annotation/aod.persistent.Annotation
%
% Private properties:
%   listeners
%
% Methods:
%   setAnnotation(obj, annotation)
%   signals = get(obj, ID, timePoints)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        % Annotation defining regions within acquired data
        Annotation    {mustBeEntityType(Annotation, 'Annotation')} = aod.core.Annotation.empty()
    end

    properties (Access = private)
        listeners
    end

    methods
        function obj = RegionResponse(name, parent, annotation, varargin)
            obj = obj@aod.core.Response(name, 'Parent', parent);
            obj.setAnnotation(annotation);

            obj.extractResponse(varargin{:});

            % Listen for changes to regions and flag for update
            obj.listeners = addlistener(obj.Annotation,... 
                'UpdatedRois', @obj.onUpdatedRois);
        end
    end

    methods
        function setAnnotation(obj, annotation)
            % Set the Annotation used to extract Region Responses
            %
            % Syntax:
            %   setAnnotation(obj, annotation)
            % -------------------------------------------------------------
            obj.Annotation = annotation;
        end

        function signals = get(obj, IDs, timePoints) 
            % Get a subregion of the data, specified by ID and/or time
            %
            % Description:
            %   Convenience method for easy access of "Data" property
            %
            % Syntax:
            %   Returns just the signals in the timetable
            % 
            % Optional input:
            %   IDs             integer(s)      (default = all)
            %       Specific rows (regions) to return
            %   timePoints      integer(s)      (default = all)
            %       Specific time points or region of time to return 
            %
            % Output:
            %   signals     double [time x rois]
            % -------------------------------------------------------------
            if isempty(obj.Data)
                error('get:NoData', 'Response Data is empty!');
            end

            signals = obj.Data.Signals;
            if nargin == 2 || isempty(timePoints)
                signals = signals(:, IDs);
            elseif nargin == 3
                if isempty(IDs)
                    signals = signals(timePoints, :);
                else
                    signals = signals(timePoints, IDs);
                end
            end
        end

        function out = loadData(obj)
            % Load data from which Response will be extracted
            %
            % Syntax:
            %   loadData(obj)
            % -------------------------------------------------------------
            out = obj.Parent.getStack();
        end

        function extractResponse(obj)
            % Get the average response over all pixels in each region
            %
            % Syntax:
            %   extract(obj)
            % -------------------------------------------------------------
            imStack = obj.loadData();

            roiMask = double(obj.Annotation.Data);
            roiList = obj.Annotation.roiIDs;
        
            A = [];
            for i = 1:obj.Annotation.numRois
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

            obj.setData(A');
        end

        function [signals, xpts] = getRoiResponse(obj, ID)
            % GETROIRESPONSE
            %
            % Syntax:
            %   [signals, xpts] = obj.getRoiResponse(ID)
            % -------------------------------------------------------------
            if isempty(obj.Responses)
                obj.load();
            end
            ID = obj.Annotation.parseRoi(ID);

            signals = obj.Data.Signals(:, ID)';
            xpts = obj.Data.Time';
        end
    end

    % Overloaded methods
    methods (Access = protected)
        function value = getLabel(obj)
            value = sprintf('Epoch%u_Responses', obj.Parent.ID);
        end
    end

    % Event callbacks
    methods (Access = private)
        function onUpdatedRois(obj, ~, ~)
            obj.load();
        end
    end
end