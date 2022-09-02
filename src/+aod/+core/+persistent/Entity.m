classdef (Abstract) Entity < handle & matlab.mixin.CustomDisplay
% ENTITY
%
% Description:
%   Parent class for all persistent entities read from an HDF5 file
%
% Constructor:
%   obj = Entity(hdfName, hdfPath)
%   obj = Entity(hdfName, hdfPath, entityFactory)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        parameters              % aod.util.Parameters
        files                   % aod.util.Parameters
        description             string
    end

    properties (SetAccess = private)
        Parent                  % aod.core.persistent.Entity
        UUID                    string
    end

    properties (Hidden, SetAccess = private)
        hdfName 
        hdfPath 
        Name                    char
        label                   char 
        entityType
        entityClassName         

        info
        factory
    end

    events 
        ChangedAttribute
        ChangedDataset
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
    end

    % Dataset methods
    methods
        function addDataset(obj, dsetName, dsetValue)

            % Format event data by whether dataset exists or not
            if ismember(dsetName, string({obj.info.Datasets.Name}))
                evtData = aod.h5.events.DatasetEvent(dsetName, dsetValue,...
                    obj.(dsetName));
            else
                evtData = aod.h5.events.DatasetEvent(dsetName, dsetValue);
            end

            notify(obj, 'ChangedDataset', evtData);
        end
    end

    % Parameter methods  % TODO: Get param
    methods
        function tf = hasParam(obj, paramName)
            % HASPARAM
            %
            % Description:
            %   Check whether parameter is present
            %
            % Syntax:
            %   tf = hasParam(obj, paramName)
            % -------------------------------------------------------------
            arguments
                obj
                paramName           char
            end
            tf = ismember(paramName, string(obj.parameters.keys));
        end

        function setParam(obj, paramName, paramValue)
            % SETPARAM
            %
            % Description:
            %   Add new parameter or change value of existing parameter
            %
            % Syntax:
            %   setParam(obj, paramName, paramValue)
            % -------------------------------------------------------------
            arguments
                obj
                paramName           char
                paramValue
            end

            if ismember(paramName, aod.h5.getSystemAttributes)
                warning("setParam:SystemAttribute",...
                    "Attribute not set, member of uneditable system attributes");
                return
            end

            evtData = aod.h5.events.AttributeEvent(obj.hdfPath, paramName, paramValue);
            notify(obj, 'ChangedAttribute', evtData);

            obj.parameters(paramName) = paramValue;
        end

        function removeParam(obj, paramName)
            % REMOVEPARAM
            %
            % Description:
            %   Remove a parameter from the entity
            %
            % Syntax:
            %   removeParam(obj, paramName)
            % -------------------------------------------------------------
            arguments
                obj
                paramName           char
            end

            if ismember(paramName, aod.h5.getSystemAttributes)
                warning("setParam:SystemAttribute",...
                    "Parameter %s not set, member of system attributes", paramName);
                return
            end
            
            if ~obj.hasParam(paramName)
                warning("removeParam:ParamNotFound",...
                    "Parameter %s not found in parameters property!", paramName);
                return
            end

            evtData = aod.h5.events.AttributeEvent(obj.hdfPath, paramName);
            notify(obj, 'ChangedAttribute', evtData);

            remove(obj.parameters, paramName);
        end
    end

    % Initialization
    methods (Access = protected)
        function [datasetNames, linkNames] = populate(obj)
            % POPULATE
            %
            % Description:
            %   Load datasets and attributes from the HDF5 file, assigning
            %   defined ones to the appropriate places. 
            % -------------------------------------------------------------
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

    % CustomDisplay methods
    methods (Access = protected)
        function header = getHeader(obj)
            if ~isscalar(obj)
                header = getHeader@matlab.mixin.CustomDisplay(obj);
            else
                headerStr = matlab.mixin.CustomDisplay.getClassNameForHeader(obj);
                header = sprintf('%s (%s, %s)\n',... 
                    headerStr, obj.label, char(obj.entityClassName));
            end
        end
    end
end 