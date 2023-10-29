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
%   numROIs
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

    properties (SetObservable, SetAccess = {?aod.core.Entity})
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

            obj.load(rois);
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

            if isnumeric(rois)
                obj.setMap(rois);
                return
            end

            if istext(rois) && isfile(rois)
                if isempty(obj.Reader)
                    obj.Reader = aod.util.findFileReader(rois);
                else
                    obj.Reader.changeFile(rois);
                end
            elseif isSubclass(rois, 'aod.common.FileReader')
                obj.Reader = rois;
            end

            obj.setMap(obj.Reader.readFile());
            if ~isempty(obj.Reader)
                obj.setFile('AnnotationData', obj.Reader.fullFile);
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

            obj.setProp('Reader', reader);
        end

        function setImage(obj, img)
            % Set an image used for annotation
            %
            % Syntax
            %   setImage(obj, img)
            % -------------------------------------------------------------
            if istext(img)
                reader = aod.util.findFileReader(img);
                data = reader.readFile();
                obj.setProp('Image', data);
                obj.setFile('Image', img);
            else
                obj.setProp('Image', img);
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

    methods (Static)
        function d = specifyDatasets(d)
            d = specifyDatasets@aod.core.Annotation(d);

            d.set("Image", "NUMBER",...
                "Size", "(:,:)", ...
                "Description", "The image used for the annotation");
            % TODO: FileReader will require more schema testing
            d.set("Reader", "OBJECT",...
                "Class", "aod.common.FileReader",...
                "Description", "File reader used to load ROIs");
            d.set("roiIDs", "INTEGER",...
                "Size", "(:,1)",...
                "Description", "A list of each ROI's IDs");
            d.set("numRois", "INTEGER",...
                "Class", "double", "Size", "(1,1)",...
                "Description", "The number of unique ROI annotations");
        end
    end
end
