classdef Rois < aod.core.Regions
% ROIS
% 
% Description:
%   Regions subclass meant for Rois in physiology experiment
% 
% Parent:
%   aod.core.Regions
%
% Constructor:
%   obj = Rois(parent, rois, imSize)
%
% Methods:
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
            elseif nargin < 3
                imSize = [];
            end
            obj@aod.core.Regions(parent, rois);
            obj.load(rois, imSize);
        end

        function load(obj, rois, imSize)
            % LOAD
            %
            % Description:
            %   Obtain data to send to setMap()
            %
            % Syntax:
            %   load(obj, rois, imSize)
            % -------------------------------------------------------------
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
            obj.setMetadata();
        end
           
        function reload(obj)
            % RELOAD
            %
            % Description:
            %   Reload ROIs (if loaded from a specific file)
            %
            % Syntax:
            %   reload(obj)
            % -------------------------------------------------------------
            if isempty(obj.Reader) 
                error('No Reader found!');
            end
            newMap = obj.Reader.reload();
            obj.setMap(newMap);
            obj.setMetadata();
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
            assert(ID <= obj.count, 'ROI is not within count!');
        end
        
        function roiID = uid2roi(obj, uid)
            % UID2ROI 
            % 
            % Description:
            %   Given a UID, return the ROI ID. Given ROI ID, return as is
            %
            % Syntax:
            %   uid = obj.roi2uid(roiID)
            % -------------------------------------------------------------
            if isnumeric(uid)
                roiID = uid;
                return
            end
            roiID = find(obj.Metadata.UID == uid);
        end

        function uid = roi2uid(obj, roiID)
            % ROI2UID 
            % 
            % Description:
            %   Given a roi ID, returns the UID. Given a UID, return as is
            %
            % Syntax:
            %   uid = obj.roi2uid(roiID)
            % -------------------------------------------------------------
            if isstring && strlength(3)
                uid = roiID;
                return
            end
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
                assert(numel(roiUIDs) == obj.count, ...
                    'Number of UIDs must equal number of ROIs');
                T = table(rangeCol(1, obj.count), roiUIDs,...
                    'VariableNames', {'ID', 'UID'});
                obj.Metadata = T;
            elseif istable(roiUIDs)
                assert(height(roiUIDs) == obj.count,...
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
    
        function clearMetadata(obj)
            obj.createMetadata(true);
        end
    end

    % Convenience analysis methods
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
        function setMetadata(obj)
            if isempty(obj.Map)
                return
            end
            if ~isempty(obj.Metadata)
                % If there were existing ROIs, make sure to append to  
                % Metadata rather than erasing existing table
                newROIs = obj.count - height(obj.Metadata);
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
                obj.Metadata = table(rangeCol(1, obj.count), ...
                    repmat("", [obj.count, 1]),...
                    'VariableNames', {'ID', 'UID'});
            end
        end
    end
end
