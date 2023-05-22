classdef Rois < aod.core.Annotation
% Regions of interest
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
% Derived Attributes (automatically calculated from Data):
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
%
% Examples:
%   % Load ROIs from a know file type 
%   obj = aod.builtin.annotations.Rois('MyRois', 'rois.csv');
%   obj.load();
%
%   % Load ROIs from a custom file type or with custom reader
%   obj = aod.builtin.annotations.Rois('MyRois',...
%       aod.builtin.readers.ImageJRoiReader('rois.zip', [100 200]));
%   obj.load();
%
%   % Load data without associated file 
%   roiData = magic(5);
%   obj = aod.builtin.annotations.Rois('MyRois', roiData);

% By Sara Patterson, 2023 (AOData)
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

            ip = aod.util.InputParser();
            addParameter(ip, 'Reader', []);
            addParameter(ip, 'Image', []);
            parse(ip, varargin{:});

            obj.setReader(ip.Results.Reader);
            obj.setImage(ip.Results.Image);

            %if isSubclass(rois, 'aod.common.FileReader')
            %    obj.Reader = rois;
            %    obj.load(obj.Reader);
            %else
            %    obj.load(rois);
            %end

            % Assign Reader, if necessary. If "rois" are text, it is 
            % assumed they represent a file name
            if istext(rois) && isfile(rois)
                obj.setFile(rois);
                if isempty(obj.Reader)
                    obj.setReader(aod.util.findFileReader(rois));
                end
                obj.load();
            end
        end
    end

    methods
        function load(obj, rois)
            % Obtain data to send to setMap()
            %
            % Syntax:
            %   load(obj, rois)
            %
            % Inputs:
            %   rois            numeric, string/char, aod.common.FileReader
            % -------------------------------------------------------------

            if nargin < 2
                obj.setMap(obj.Reader.readFile());
                return
            end

            if ~isa(obj.Data, 'double')
                obj.setMap(rois);
                return
            end

            if isfile(rois)
                if isempty(obj.Reader)
                    obj.Reader = aod.util.findFileReader(rois);
                else
                    obj.Reader.changeFile(rois);
                end
            elseif isSubclass(rois, 'aod.common.FileReader')
                obj.Reader = rois;
            end

            obj.setMap(obj.Reader.readFile());
            obj.setFile('ROIs', obj.Reader.fullFile);
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
            % Set the FileReader
            %
            % Syntax:
            %   setReader(obj, reader)
            % -------------------------------------------------------------

            if nargin < 2 || isempty(reader)
                obj.Reader = [];
                return 
            end

            if ~isSubclass(reader, 'aod.common.FileReader')
                error('setReader:InvalidType',...
                    'Input must be a subclass of aod.common.FileReader');
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
