classdef Rois < aod.builtin.annotations.Rois
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
%   ID = parseRoi(obj, ID)
%   roiID = uid2roi(obj, UID)
%   uid = roi2uid(obj, roiID)
%   addRoiUID(obj, roiID, roiUID)
%   setRoiUIDs(obj, roiUIDs)
%
% Inherited methods:
%   load(obj)
%   reload(obj)
%   setImage(obj, im)
%
%
% Protected methods:
%   setMap(obj, map);

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    events 
        UpdatedRois
    end

    properties (SetAccess = protected)
        % The size of the image used to annotate ROIs
        Size                {mustBeInteger}
        % Unique identifiers of ROIs
        Metadata            table            = table.empty()
    end

    methods
        function obj = Rois(name, rois, varargin)
            ip = aod.util.InputParser();
            addParameter(ip, 'Size', [], @isnumeric);
            parse(ip, varargin{:});

            if istext(rois) && endsWith(rois, '.zip')
                if isempty(ip.Results.Size)
                    error('Rois:NoSizeSpecified',...
                        'Must specify Size to use ImageJRoiReader');
                end
                rois = aod.builtin.readers.ImageJRoiReader(rois, ip.Results.Size);
            end
            obj = obj@aod.builtin.annotations.Rois(name, rois, varargin{:});
            
            if ~isempty(ip.Results.Size)
                obj.Size = ip.Results.Size;
            end
        end
    end

    methods
        function load(obj, rois)
            load@aod.builtin.annotations.Rois(obj, rois);
            obj.setMetadata();
        end
           
        function reload(obj)
            reload@aod.builtin.annotations.Rois(obj);
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
            assert(ID <= obj.Count, 'ROI is not within count!');
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
                newROIs = obj.numRois - height(obj.Metadata);
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
                obj.Metadata = table(rangeCol(1, obj.numRois), ...
                    repmat("", [obj.numRois, 1]),...
                    'VariableNames', {'ID', 'UID'});
            end
        end
    end
end
