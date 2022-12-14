classdef Rois < aod.core.Annotation
% ROIS
% 
% Description:
%   ROIs in physiology experiment
% 
% Parent:
%   aod.core.Annotation
%
% Constructor:
%   obj = Rois(name, rois)
%   obj = Rois(name, rois, 'Size', value, 'Source', source)
%
% Optional Parameters:
%   Size            % needed for loading ImageJRois, otherwise calculated
% Optional Parameters (inherited from aod.core.Annotation):
%   Source          aod.core.Source
%
% Derived Parameters (automatically calculated from Data):
%   Count
%   RoiIDs
%
% Methods:
%   load(obj)
%   reload(obj)
%   setImage(obj, im)
%
%   ID = parseRoi(obj, ID)
%   roiID = uid2roi(obj, UID)
%   uid = roi2uid(obj, roiID)
%   addRoiUID(obj, roiID, roiUID)
%   setRoiUIDs(obj, roiUIDs)
%
% Protected methods:
%   setMap(obj, map);
% -------------------------------------------------------------------------

    events 
        UpdatedRois
    end

    properties (SetAccess = protected)
        Metadata            table            = table.empty()
        Image
    end

    properties (SetAccess = private)
        Size(1,2)           {mustBeInteger}         = [0 0]
    end

    % Enables quick access to commonly-used parameters
    properties (Dependent)
        count
        roiIDs
    end

    methods
        function obj = Rois(name, rois, varargin)
            obj = obj@aod.core.Annotation(name, varargin{:});

            ip = aod.util.InputParser();
            addParameter(ip, 'Size', [], @isnumeric);
            parse(ip, varargin{:});
            
            obj.Size = ip.Results.Size;

            obj.load(rois);
        end

        function value = get.count(obj)
            value = obj.getParam('Count', aod.util.ErrorTypes.NONE);
        end

        function value = get.roiIDs(obj)
            value = obj.getParam('RoiIDs', aod.util.ErrorTypes.NONE);
        end
    end

    methods
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
                if ~isnumeric(obj.Data)
                    obj.Data = double(obj.Data);
                end
                obj.setMap(rois);
                obj.Reader = [];
            else
                roiFileName = char(rois);
                if endsWith(roiFileName, 'zip')
                    obj.Reader = aod.builtin.readers.ImageJRoiReader(roiFileName, imSize);
                elseif endsWith(roiFileName, 'csv')
                    obj.Reader = aod.util.readers.CsvReader(roiFileName);
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

        function setImage(obj, img)
            % SETIMAGE
            % 
            % Description:
            %   Set an image used for annotation
            %
            % Syntax
            %   setImage(obj, img)
            % -------------------------------------------------------------
            if istext(img)
                obj.Image = imread(img);
                obj.setFile('Image', img);
            else
                obj.Image = img;
            end
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

    methods (Access = protected)
        function setMetadata(obj)
            if isempty(obj.Data)
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

    methods (Access = protected)     
        function setMap(obj, map)
            % SETMAP
            %
            % Description:
            %   Assigns ROI map to Data property and gets derived metadata
            %
            % Syntax:
            %   setMap(obj, data);
            % -------------------------------------------------------------
            obj.setData(double(map));

            IDs = unique(obj.Data);
            IDs(obj.roiIDs == 0) = [];
            roiCount = nnz(unique(obj.Data));

            obj.setParam('RoiIDs', IDs);
            obj.setParam('Count', roiCount);
        end
    end
end
