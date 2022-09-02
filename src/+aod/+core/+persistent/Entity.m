classdef Entity < handle

    properties %(SetAccess = private)
        entityClassName         string
        parameters              % aod.util.Parameters
        files                   % aod.util.Parameters
        UUID                    string
        description             string
        Name                    char
        label                   char 
        Parent
    end

    properties (Hidden, SetAccess = private)
        hdfName 
        hdfPath 
        info
        entityType
        parentLink 
    end

    properties
        factory
    end

    events 
        ChangedDescription
        ChangedNote
        ChangedAttribute
    end

    methods
        function obj = Entity(hdfName, hdfPath, entityFactory)
            obj.hdfName = hdfName;
            obj.hdfPath = hdfPath;
            obj.factory = entityFactory;

            % Initialize parameters 
            obj.files = aod.util.Parameters();
            obj.parameters = aod.util.Parameters();

            % Create entity from file
            obj.populate();
        end

        function setParamTest(obj, paramName, paramValue)
            evtData = aod.h5.events.AttributeEvent(obj.hdfPath, paramName, paramValue);
            notify(obj, 'ChangedAttribute', evtData);
            disp('Notification Sent!')
        end
    end

    % Initialization
    methods (Access = protected)
        function [datasetNames, linkNames] = populate(obj)
            obj.info = h5info(obj.hdfName, obj.hdfPath);

            % DATASETS
            if ~isempty(obj.info.Datasets)
                datasetNames = string({obj.info.Datasets.Name});
            else
                datasetNames = [];
            end
            if ismember(datasetNames, "files")
                obj.files = obj.loadDataset(datasetNames, 'files', 'aod.util.Parameters');
            end

            % LINKS
            if ~isempty(obj.info.Links)
                linkNames = string({obj.info.Links.Name});
            else
                linkNames = [];
            end
            obj.Parent = obj.loadLink(linkNames, 'Parent');

            % ATTRIBUTES
            if ~isempty(obj.info.Attributes)
                attributeNames = string({obj.info.Attributes.Name});
            else
                attributeNames = [];
            end

            % Special attributes (universal ones mapping to properties)
            specialAttributes = ["UUID", "description", "Class", "EntityType"];
            obj.label = obj.loadAttribute(attributeNames, 'label');
            obj.UUID = obj.loadAttribute(attributeNames, 'UUID');
            obj.entityType = obj.loadAttribute(attributeNames, 'EntityType');
            obj.entityClassName = obj.loadAttribute(attributeNames, 'Class');

            % Optional special attributes which may not be present
            obj.description = obj.loadAttribute(attributeNames, 'description');
            obj.Name = obj.loadAttribute(attributeNames, 'Name');

            % Parse the remaining attributes
            for i = 1:numel(attributeNames)
                if ~ismember(attributeNames(i), specialAttributes)
                    obj.parameters(char(attributeNames(i))) = ...
                        h5readatt(obj.hdfName, obj.hdfPath, attributeNames(i));
                end
            end
        end
    end

    % Loading methods
    methods (Access = protected)
        function a = loadAttribute(obj, attNames, name)
            % LOADLINK
            %
            % Description:
            %   Check if an attribute is present and if so, read it
            %
            % Syntax:
            %   d = loadLink(obj, linkNames, name)
            % -------------------------------------------------------------
            if isempty(attNames) || ~ismember(name, attNames)
                a = [];
                return
            end
            a = h5readatt(obj.hdfName, obj.hdfPath, name);
        end

        function e = loadLink(obj, linkNames, name)
            % LOADLINK
            %
            % Description:
            %   Check if a link is present and if so, read it
            %
            % Syntax:
            %   d = loadLink(obj, linkNames, name)
            % -------------------------------------------------------------
            if isempty(linkNames) || ~ismember(name, linkNames)
                e = [];
                return
            end
            idx = find(linkNames == name);
            linkPath = obj.info.Links(idx).Value{1};
            e = obj.factory.create(linkPath);
        end

        function d = loadDataset(obj, dsetNames, name, varargin)
            % LOADDATASET
            %
            % Description:
            %   Check if a dataset is present and if so, read it
            %
            % Syntax:
            %   d = loadDataset(obj, dsetNames, name, varargin)
            % -------------------------------------------------------------
            if isempty(dsetNames) && ~ismember(name, dsetNames)
                d = [];
                return
            end
            d = aod.h5.readDatasetByType(obj.hdfName, obj.hdfPath, name, varargin{:});
        end

        function c = loadContainer(obj, containerName)
            % LOADCONTAINER
            %
            % Description:
            %   Load an entity container
            %
            % Syntax:
            %   c = loadContainer(obj, containerName)
            % -------------------------------------------------------------
            c = aod.core.persistent.EntityContainer(...
                aod.h5.HDF5.buildPath(obj.hdfPath, containerName), obj.factory);
        end
    end

    % Dynamic property assignment methods
    methods (Access = protected)
        function setDatasetsToDynProps(obj, datasetNames)
            % SETDATASETSTODYNPROPS
            %
            % Description:
            %   Creates a dynamic property for all datasets not matching an
            %   existing property of the class
            %
            % Syntax:
            %   setDatasetsToDynProps(obj)
            %   setDatasetsToDynProps(obj, dsetNames)
            % -------------------------------------------------------------
            if nargin < 2
                if isempty(obj.info.Datasets)
                    return
                else
                    datasetNames = string({obj.info.Datasets.Name});
                end
            end

            if isempty(datasetNames)
                return
            end

            for i = 1:numel(datasetNames)
                if ~isprop(obj, datasetNames(i))
                    obj.addprop(datasetNames(i));
                    obj.(datasetNames(i)) = aod.h5.readDatasetByType(...
                        obj.hdfName, obj.hdfPath, char(datasetNames(i)));
                end
            end
        end

        function setLinksToDynProps(obj, linkNames)
            % SETLINKSTODYNPROPS
            %
            % Description:
            %   Creates a dynamic property for all ad hoc links not already
            %   set as an existing property of the class
            %
            % Syntax:
            %   setLinksToDynProps(obj)
            %   setLinksToDynProps(obj, dsetNames)
            % -------------------------------------------------------------
            if nargin < 2
                if isempty(obj.info.Links)
                    return
                else
                    linkNames = string({obj.info.Links.Name});
                end
            end

            if isempty(linkNames)
                return
            end

            for i = 1:numel(linkNames)
                if ~isprop(obj, linkNames(i))
                    obj.(linkNames(i)) = obj.loadLink(linkNames, linkNames(i));
                end
            end
        end
    end
end 