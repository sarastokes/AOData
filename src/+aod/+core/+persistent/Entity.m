classdef Entity < handle & dynamicprops

    properties (SetAccess = private)
        entityClassName         string
        parameters              = aod.core.Parameters()
        files                   = aod.core.Parameters()
        UUID                    string
        description             char
        label                   char 
        shortLabel              char
    end

    properties (Dependent)
        Parent
    end

    properties (Access = private)
        hdfName 
        hdfPath 
        entityType
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
        function obj = Entity(hdfName, hdfPath, entityType)
            if nargin < 3
                obj.entityFactory = @(x)aod.core.EntityTypes.(x);
            end
            obj.hdfName = hdfName;
            obj.hdfPath = hdfPath;
            obj.populateEntityFromFile();
        end

        function value = get.Parent(obj)
            % TODO Need Entity Manager
            value = [];
        end
    end

    methods (Access = protected)
        function populateEntityFromFile(obj)
            info = h5info(obj.hdfName, obj.hdfPath);

            attributeNames = string({info.Attributes.Name});
            datasetNames = string({info.Datasets.Name});
            linkNames = string({info.Links.Name})

            specialAttributes = ["description", "Class", "EntityType"];


            % Handle special attributes
            obj.setDescription(h5readatt(obj.hdfName, obj.hdfPath, 'description'));
            obj.UUID = h5readatt(obj.hdfName, obj.hdfPath, 'UUID');
            % Parse the remaining attributes
            for i = 1:numel(attributeNames)
                if ~ismember(attributeNames(i), specialAttributes)
                    obj.parameters(char(attributeNames(i))) = ...
                        h5readatt(obj.hdfName, obj.hdfPath, attributeNames(i));
                end
            end
        end
    end
end 