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
%   Annotation
%
% Private properties:
%   listeners
%
% Methods:
%   setAnnotation(obj, annotation)
%   signals = getData(obj, ID)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        Annotation
    end

    properties (Access = private)
        listeners
    end

    methods
        function obj = RegionResponse(name, parent, annotation, varargin)
            obj = obj@aod.core.Response(name);
            obj.setParent(parent);
            obj.setAnnotation(annotation);

            obj.load(varargin{:});

            % Listen for changes to regions and flag for update
            obj.listeners = addlistener(obj.Annotation,... 
                'UpdatedRois', @obj.onUpdatedRois);
        end
    end

    methods
        function setAnnotation(obj, annotation)
            % SETANNOTATION
            %
            % Syntax:
            %   setAnnotation(obj, annotation)
            % -------------------------------------------------------------
            assert(isSubclass(annotation, {'aod.core.Annotation', 'aod.persistent.Annotation'}),...
                'Input must be subclass of aod.core.Annotation');
            obj.Annotation = annotation;
        end

        function signals = getData(obj, IDs, timePoints) 
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
            elseif nargin == 3
                if isempty(IDs)
                    signals = signals(timePoints, :);
                else
                    signals = signals(timePoints, IDs);
                end
            end
        end

        function load(obj)
            % LOAD
            %
            % Description:
            %   Get the average response over all pixels in ROI
            %
            % Syntax:
            %   load(obj)
            % -------------------------------------------------------------
            roiMask = double(obj.Annotation.Data);
            h = obj.ancestor(aod.core.EntityTypes.EXPERIMENT);
            sampleRate = h.sampleRate;
            imStack = obj.Parent.getStack();
            roiList = obj.Annotation.roiIDs;
        
            A = [];
            for i = 1:obj.Annotation.Count
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

            obj.setData(A);
            obj.setTiming(aod.core.timing.TimeRate(1/sampleRate,... 
                size(imStack,3), 1/sampleRate));
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