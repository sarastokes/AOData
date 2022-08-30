classdef Entity < handle

    properties %(SetAccess = private)
        entityClassName         string
        parameters              % aod.core.Parameters
        Files                   % aod.core.Parameters
        UUID                    string
        description             string
        Name                    char
        label                   char 
        Parent
    end

    properties %(Access = protected)
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
        AddedParameter
        RemovedParameter
        ChangedParameter
    end

    methods
        function obj = Entity(hdfName, hdfPath, entityFactory)
            obj.hdfName = hdfName;
            obj.hdfPath = hdfPath;
            obj.factory = entityFactory;

            % Initialize parameters 
            obj.Files = aod.core.Parameters();
            obj.parameters = aod.core.Parameters();

            % Create entity from file
            obj.populate();
        end
    end

    methods (Access = protected)
        function [datasetNames, linkNames] = populate(obj)
            obj.info = h5info(obj.hdfName, obj.hdfPath);

            % DATASETS
            if ~isempty(obj.info.Datasets)
                datasetNames = string({obj.info.Datasets.Name});
            else
                datasetNames = [];
            end

            if ismember("Name", datasetNames)
                obj.Name = aod.h5.readDatasetByType(obj.hdfName, obj.hdfPath, 'Name');
            end

            if ismember("Files", datasetNames)
                obj.Files = aod.h5.readDatasetByType(obj.hdfName, obj.hdfPath, 'Files',...
                    'aod.core.Parameters');
            end

            % LINKS
            if ~isempty(obj.info.Links)
                linkNames = string({obj.info.Links.Name});
            else
                linkNames = [];
            end

            if ~isempty(linkNames)
                if ismember("Parent", linkNames)
                    idx = find(linkNames == "Parent");
                    obj.parentLink = obj.info.Links(idx).Value{1};
                    obj.Parent = obj.factory.create(obj.parentLink);
                end
            end

            % ATTRIBUTES
            attributeNames = string({obj.info.Attributes.Name});

            % Special attributes (universal ones mapping to properties)
            specialAttributes = ["UUID", "description", "Class", "EntityType"];
            obj.UUID = h5readatt(obj.hdfName, obj.hdfPath, 'UUID');
            obj.entityType = h5readatt(obj.hdfName, obj.hdfPath, 'EntityType');
            obj.entityClassName = h5readatt(obj.hdfName, obj.hdfPath, 'Class');
            % Optional special attributes which may not be present
            if ismember("description", attributeNames)
                obj.description = h5readatt(obj.hdfName, obj.hdfPath, 'description');
            end

            % Parse the remaining attributes
            for i = 1:numel(attributeNames)
                if ~ismember(attributeNames(i), specialAttributes)
                    obj.parameters(char(attributeNames(i))) = ...
                        h5readatt(obj.hdfName, obj.hdfPath, attributeNames(i));
                end
            end
        end

        function e = loadLink(obj, linkNames, name)
            % LOADLINK
            %
            % Description:
            %   Check if a link is present and if so, assign to property
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

        function d = loadDataset(obj, dsetNames, name)
            % LOADDATASET
            %
            % Description:
            %   Check if a dataset is present and if so, assign to property
            %
            % Syntax:
            %   d = loadDataset(obj, dsetNames, name)
            % -------------------------------------------------------------
            if ~isempty(dsetNames) && ismember(name, dsetNames)
                d = aod.h5.createDatasetByType(obj.hdfName, obj.hdfPath, name);
            else
                d = [];
            end
        end

        function setDatasetsToDynProps(obj, datasetNames)
            % SETDATASETSTODYNPROPS
            %
            % Description:
            %   Creates a dynamic property for all datasets not matching an
            %   existing property of the class
            %
            % Syntax:
            %   setDatasetsToDynProps(obj)
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
                if ~isprop(obj.linkNames(i))
                    obj.(linkNames(i)) = obj.loadLink(linkNames, linkNames(i));
                end
            end
        end
    end
end 