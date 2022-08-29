classdef Entity < handle

    properties (SetAccess = private)
        entityClassName         string
        parameters              % aod.core.Parameters
        files                   % aod.core.Parameters
        UUID                    string
        description             string
        Name                    char
        label                   char 
        shortLabel              char
    end

    properties (Dependent)
        Parent
    end

    properties (Access = protected)
        hdfName 
        hdfPath 
        info
        entityType
        entityFactory
        parentUUID 
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
            if nargin < 3 || isempty(entityFactory)
                obj.entityFactory = @(x)aod.core.EntityTypes.(x);
            else
                obj.entityFactory = entityFactory;
            end
            obj.hdfName = hdfName;
            obj.hdfPath = hdfPath;

            % Initialize parameters 
            obj.files = aod.core.Parameters();
            obj.parameters = aod.core.Parameters();

            % Create entity from file
            obj.populateEntityFromFile();
        end

        function value = get.Parent(obj)
            % TODO Figure this out later
            value = obj.parentUUID;
        end
    end

    methods (Access = protected)
        function [datasetNames, linkNames] = populateEntityFromFile(obj)
            obj.info = h5info(obj.hdfName, obj.hdfPath);

            if ~isempty(obj.info.Datasets)
                datasetNames = string({obj.info.Datasets.Name});
            else
                datasetNames = [];
            end

            if ismember("Name", datasetNames)
                obj.Name = aod.h5.readDatasetByType(obj.hdfName, obj.hdfPath, 'Name');
            end

            % LINKS
            if ~isempty(obj.info.Links)
                linkNames = string({obj.info.Links.Name});
            else
                linkNames = [];
            end

            % ATTRIBUTES
            attributeNames = string({obj.info.Attributes.Name});

            % Special attributes (universal ones mapping to properties)
            specialAttributes = ["UUID", "description", "Class", "EntityType"];
            obj.UUID = h5readatt(obj.hdfName, obj.hdfPath, 'UUID');
            obj.entityType = h5readatt(obj.hdfName, obj.hdfPath, 'EntityType');
            obj.entityClassName = h5readatt(obj.hdfName, obj.hdfPath, 'Class');
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

            for i = 1:numel(datasetNames)
                if ~isprop(obj, datasetNames(i))
                    obj.addprop(datasetNames(i));
                    obj.(datasetNames(i)) = aod.h5.readDatasetByType(...
                        obj.hdfName, obj.hdfPath, char(datasetNames(i)));
                end
            end
        end
    end
end 