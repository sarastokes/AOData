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
%   obj = Rois(name, rois, 'Source', source)
%
% Optional Properties (inherited from aod.core.Annotation):
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
% Protected methods:
%   setMap(obj, map);

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        % The image used to annotate the ROIs
        Image
        % The FileReader used to import ROIs
        Reader
    end

    % Properties set internally
    properties (SetAccess = protected)
        % The total number of ROIs
        numRois
        % The integer identifier of each ROI
        roiIDs
    end

    methods
        function obj = Rois(name, rois, varargin)
            obj = obj@aod.core.Annotation(name, varargin{:});

            if isSubclass(rois, 'aod.util.FileReader')
                obj.Reader = rois;
                obj.load([]);
            else
                
            end

            ip = aod.util.InputParser();
            addParameter(ip, 'Reader', []);
            parse(ip, varargin{:});
            
            reader = ip.Results.Reader;

            if ~isempty(reader)
                obj.setReader(@() reader(rois));
            end

            % Assign reader, if necessary. If rois are text, it is 
            % assumed they represent a file name
            if isempty(obj.Reader) && istext(rois)
                obj.setReader(aod.util.findFileReader(rois));
            end

            obj.load(rois);
        end
    end

    methods
        function load(obj, rois)
            % Obtain data to send to setMap()
            %
            % Syntax:
            %   load(obj, rois, imSize)
            % -------------------------------------------------------------
            if isSubclass(rois, 'aod.util.FileReader')
                obj.setMap(obj.Reader.readFile());
                if ~isa(obj.Data, 'double')
                    obj.Data = im2double(obj.Data);
                end
            else
                if ~isa(obj.Data, 'double')
                    obj.Data = double(obj.Data);
                end
                obj.setMap(rois);
            end
        end
           
        function reload(obj)
            % Reload ROIs (if loaded from a specific file)
            %
            % Syntax:
            %   reload(obj)
            % -------------------------------------------------------------
            if isempty(obj.Reader) 
                error('reload:NoReader',... 
                    'No Reader found for reloading ROIs from a file!');
            end
            newMap = obj.Reader.reload();
            obj.setMap(newMap);
            obj.setMetadata();
        end

        function setReader(obj, reader)
            if nargin < 2 || isempty(reader)
                obj.Reader = [];
                return 
            end

            if ~isSubclass(reader, 'aod.util.FileReader')
                error('setReader:InvalidType',...
                    'Input must be a subclass of aod.util.FileReader');
            end
            
            obj.Reader = reader;
        end

        function setImage(obj, img)
            % Set an image used for annotation
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

    methods (Access = protected)     
        function setMap(obj, map)
            % Assigns ROI map to Data property and gets derived metadata
            %
            % Syntax:
            %   setMap(obj, data);
            % -------------------------------------------------------------
            obj.setData(double(map));

            IDs = unique(obj.Data);
            IDs(IDs == 0) = [];
            roiCount = nnz(unique(obj.Data));

            obj.roiIDs = IDs;
            obj.numRois = roiCount;
        end
    end
end
