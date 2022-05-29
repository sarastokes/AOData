classdef Regions < aod.core.Entity

    properties (SetAccess = protected)
        Map         double
        Count(1,1) {mustBeInteger}  = 0
        Metadata    table           = table.empty()
    end

    properties %(Access = protected)
        Reader
    end

    methods (Abstract)
        load(obj, varargin)
    end

    methods
        function obj = Regions(parent, rois, varargin)

            obj.allowableParentTypes = {'aod.core.Dataset', 'aod.core.Epoch'};

            if nargin > 0 && ~isempty(parent)
                obj.setParent(parent);
            end

            if nargin > 1 && ~isempty(rois)
                if ~ischar(rois) || ~isstring(rois)
                    obj.Map = rois;
                end
            end
        end

        function reload(obj)
            if isempty(obj.Reader) 
                error('No Reader found!');
            end
            newMap = obj.Reader.reload();
            obj.setMap(newMap);
        end
    end

    % Metadata-related methods
    methods
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
            obj.roiUIDs = sortrows(obj.Metadata, 'ID');
        end
    end

    methods (Access = protected)
        function setMap(obj, roiMap)
            obj.Map = roiMap;
            obj.Count = nnz(unique(obj.Map));


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
