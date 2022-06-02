classdef Regions < aod.core.Regions

    properties (SetAccess = private)
        Size(1,2)           {mustBeInteger}         = [0 0]
    end

    methods
        function obj = Regions(parent, rois, imSize)
            if nargin == 0
                parent = [];
                rois = [];
                imSize = [];
            end
                
            obj@aod.core.Regions(parent, rois);
            
            obj.load(rois, imSize);
        end

        function load(obj, rois, imSize)
            if nargin == 3
                obj.Size = imSize;
            else
                imSize = obj.Size;
            end

            if isnumeric(rois)
                if ~isdouble(obj.rois)
                    obj.rois = double(obj.rois);
                end
                obj.setMap(rois);
                obj.Reader = [];
            else
                roiFileName = char(rois);
                if endsWith(roiFileName, 'zip')
                    obj.Reader = ao.builtin.readers.ImageJRoiReader(roiFileName, imSize);
                elseif endsWith(roiFileName, 'csv')
                    obj.Reader = ao.builtin.readers.CsvReader(roiFileName);
                end
                obj.setMap(obj.Reader.read());
            end
        end
    end

    methods
        function xy = getCentroids(obj, ID)
            % GETCENTROIDS
            %
            % Description:
            %   Get the centroids of all rois (default) or specific roi(s)
            %
            % Syntax:
            %   xy = obj.getCentroids(ID)
            %
            % Optional inputs:
            %   ID          numeric
            %       Specific roi ID(s), otherwise returns all rois
            % -------------------------------------------------------------
            S = regionprops("table", obj.Map, "Centroid");
            xy = S.Centroid;
            if nargin == 2
                xy = xy(ID,:);
            end
        end
          
    end
end
