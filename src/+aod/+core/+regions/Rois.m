classdef Rois < aod.core.Regions
% ROIS
% 
% Description:
%   Regions subclass meant for Rois in physiology experiment
%
% Methods
%   load(obj)
%   reload(obj)
%   ID = parseRoi(obj, ID)
%   roiID = uid2roi(obj, UID)
%   uid = roi2uid(obj, roiID)
%   addRoiUID(obj, roiID, roiUID)
%   setRoiUIDs(obj, roiUIDs)
% -------------------------------------------------------------------------

    events 
        UpdatedRois
    end

    properties (SetAccess = protected)
        Metadata            table            = table.empty()
    end

    properties (SetAccess = private)
        Size(1,2)           {mustBeInteger}         = [0 0]
    end

    methods
        function obj = Rois(parent, rois, imSize)
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
           
        function reload(obj)
            if isempty(obj.Reader) 
                error('No Reader found!');
            end
            newMap = obj.Reader.reload();
            obj.setMap(newMap);
            notify(obj, 'UpdatedRois');
        end
    end

    % Metadata-related methods
    methods
        function ID = parseRoi(obj, ID)
            if ischar(ID)
                ID = string(upper(ID));
            end
            if isstring(ID)
                ID = obj.uid2roi(ID);
                return;
            end
            assert(ID <= obj.Count, 'ROI is not within Count!');
        end
        
        function roiID = uid2roi(obj, uid)
            % UID2ROI 
            % 
            % Description:
            %   Given a UID, return the corresponding ROI ID
            %
            % Syntax:
            %   uid = obj.roi2uid(roiID)
            % -------------------------------------------------------------
            roiID = find(obj.Metadata.UID == uid);
        end

        function uid = roi2uid(obj, roiID)
            % ROI2UID 
            % 
            % Description:
            %   Given a roi ID, returns the UID
            %
            % Syntax:
            %   uid = obj.roi2uid(roiID)
            % -------------------------------------------------------------
            if roiID > height(obj.Metadata)
                error('Roi ID %u not in metadata', roiID);
            end
            uid = obj.Metadata{roiID, 'UID'};
        end
        
        function addRoiUID(obj, roiID, roiUID)
            % ADDROIUID
            %
            % Description:
            %   Assign a specific roi UID
            %
            % Syntax:
            %   obj.addRoiUID(roiID, UID)
            % -------------------------------------------------------------

            assert(isstring(roiUID) & strlength(roiUID) == 3, ...
                'roiUID must be string 3 characters long')
            obj.Metadata(obj.Metadata.ID == roiID, 'UID') = roiUID;
        end

        function setRoiUIDs(obj, roiUIDs)
            % SETROIUIDS
            %
            % Description:
            %   Assign a table to the roiUIDs property
            %
            % Syntax:
            %   obj.setRoiUIDs(roiUIDs)
            % -------------------------------------------------------------
            if isstring(roiUIDs)
                roiUIDs = roiUIDs(:);
                assert(numel(roiUIDs) == obj.Count, ...
                    'Number of UIDs must equal number of ROIs');
                T = table(rangeCol(1, obj.Count), roiUIDs,...
                    'VariableNames', {'ID', 'UID'});
                obj.Metadata = T;
            elseif istable(roiUIDs)
                assert(height(roiUIDs) == obj.Count,...
                    'Number of UIDs must equal number of ROIs');
                assert(~isempty(cellfind(roiUIDs.Properties.VariableNames, 'UID')),...
                    'roiUID table must have a column named UID');
                assert(~isempty(cellfind(roiUIDs.Properties.VariableNames, 'ID')),...
                    'roiUID table must have a column named ID');

                obj.Metadata = roiUIDs; 
            else
                error('Invalid input!');
            end
            obj.Metadata = sortrows(obj.Metadata, 'ID');
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

    methods (Access = protected)
        function setMap(obj, roiMap)
            setMap@aod.core.Regions(obj, roiMap);

            % If there were existing ROIs, make sure to append to Metadata 
            % rather than erasing existing table
            if ~isempty(obj.Metadata)
                newROIs = obj.Count - height(obj.Metadata);
                newTable = table(height(obj.Metadata) + rangeCol(1, newROIs),...
                    repmat("", [newROIs, 1]), 'VariableNames', {'ID', 'UID'});
                newTable = [obj.Metadata; newTable];
                obj.Metadata = newTable;
            else
                obj.createMetadata();
            end
        end

        function createMetadata(obj, forceOverwrite)
            if nargin < 2
                forceOverwrite = false;
            end
            if isempty(obj.Metadata) || forceOverwrite
                obj.Metadata = table(rangeCol(1, obj.Count), ...
                    repmat("", [obj.Count, 1]),...
                    'VariableNames', {'ID', 'UID'});
            end
        end
    end
end
