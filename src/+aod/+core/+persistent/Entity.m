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
        % Entity properties
        Name                    char
        label                   char 
        entityType
        entityClassName         

        % HDF5 properties
        hdfName 
        hdfPath 
        linkNames
        dsetNames
        attNames

        % Persistence properties
        factory
    end

    events 
        ChangedFile
        ChangedDataset
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
            if ~isempty(obj.hdfName)
                obj.populate();
            end
        end
    end

    % Navigation methods
    methods
        function h = ancestor(obj, entityType)
            % ANCESTOR
            %
            % Description:
            %   Recursively search Parent for entity matching entityType
            %
            % Syntax:
            %   h = ancestor(obj, entityType)
            %
            % Examples:
            %   h = obj.ancestor(aod.core.EntityTypes.EXPERIMENT)
            %   h = obj.ancestor('experiment')
            % -------------------------------------------------------------
            entityType = aod.core.EntityTypes.get(entityType);

            h = obj;
            while h.EntityType ~= entityType
                h = h.Parent;
                if isempty(h)
                    break
                end
            end
        end
    end

    % Dataset methods
    methods
        function addDataset(obj, dsetName, dsetValue)
            % ADDDATASET
            %
            % Description:
            %   Add a new dataset to the entity
            %
            % Syntax:
            %   addDataset(obj, dsetName, dsetValue)
            % -------------------------------------------------------------

            newDset = ~obj.ismember(dsetName, string({obj.dsetNames}));
            if newDset
                evtData = aod.h5.events.DatasetEvent(dsetName, dsetValue);
            else
                evtData = aod.h5.events.DatasetEvent(dsetName, dsetValue,...
                    obj.(dsetName));
            end
            notify(obj, 'ChangedDataset', evtData);

            if newDset
                obj.addprop(dsetName)
            end
            obj.(dsetName) = dsetValue;

            obj.loadInfo();
        end

        function removeDataset(obj, dsetName)
            % REMOVEDATASET
            %
            % Description:
            %   Remove a dataset from the entity
            %
            % Syntax:
            %   removeDataset(obj, dsetName)
            % -------------------------------------------------------------

            if ~obj.ismember(dsetName, string({obj.dsetNames}))
                error("removeDataset:DatasetDoesNotExist",...
                    "Dataset %s not found", dsetName);
            end

            evtData = aod.h5.events.DatasetEvent(dsetName);
            notify(obj, 'ChangedDataset', evtData);

            p = findprop(obj, dsetName);
            delete(p);

            obj.loadInfo();
        end
    end

    % Parameter methods
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

            tf = obj.ismember(paramName, string(obj.parameters.keys));
        end

        function out = getParam(obj, paramName, errorType)
            % GETPARAM
            %
            % Description:
            %   Check whether parameter is present
            %
            % Syntax:
            %   out = getParam(obj, paramName)
            %   out = getParam(obj, paramName, errorType)
            % -------------------------------------------------------------
            import aod.util.ErrorTypes
            if nargin < 3
                errorType = ErrorTypes.WARNING;
            end

            if ~obj.hasParam(paramName)
                switch errorType 
                    case ErrorTypes.ERROR
                        error("getParam:ParamNotFound",...
                            "Parameter %s not present", paramName);
                    case ErrorTypes.WARNING
                        warning("getParam:ParamNotFound",...
                            "Parameter %s not present", paramName);
                        out = [];
                        return
                    case ErrorTypes.NONE
                        out = [];
                        return
                end
            else
                out = obj.parameters(paramName);
            end
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

            if ismember(paramName, aod.h5.getSystemAttributes())
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

            if ismember(paramName, aod.h5.getSystemAttributes())
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

            obj.loadInfo();
        end
    end

    % File methods
    methods
        function tf = hasFile(obj, fileName)
            arguments
                obj
                fileName            char
            end

            tf = obj.ismember(fileName, string(obj.files.keys));
        end

        function out = getFile(obj, fileName, errorType)
            arguments
                obj
                fileName            char
                errorType           = aod.util.ErrorTypes.WARNING
            end
            
            import aod.util.ErrorTypes

            if ~obj.hasFile(fileName)
                switch errorType 
                    case ErrorTypes.ERROR
                        error("getFile:FileNotFound",...
                            "File %s not present", fileName);
                    case ErrorTypes.WARNING
                        warning("getFile:FileNotFound",...
                            "File %s not present", fileName);
                        out = [];
                        return
                    case ErrorTypes.NONE
                        out = [];
                        return
                end
            else
                out = obj.files(fileName);
            end
        end

        function removeFile(obj, fileName)
            % REMOVEFILE
            %
            % Description:
            %   Remove a file from entity's file directory
            %
            % Syntax:
            %   removeFile(obj, fileName)
            % -------------------------------------------------------------
            arguments
                obj
                fileName           char
            end

            if ~obj.hasFile(fileName)
                warning("removeFile:FileNotFound",...
                    "File %s not found in files property!", fileName);
                return
            end

            evtData = aod.h5.events.FileEvent(obj.hdfPath, fileName);
            notify(obj, 'ChangedFile', evtData);

            remove(obj.files, fileName);

            obj.loadInfo();
        end
    end

    % Initialization
    methods (Access = protected)
        function populate(obj)
            % POPULATE
            %
            % Syntax:
            %   populate(obj)
            %
            % Description:
            %   Load datasets and attributes from the HDF5 file, assigning
            %   defined ones to the appropriate places. 
            % -------------------------------------------------------------
            obj.loadInfo();

            % DATASETS
            if obj.ismember('files', obj.dsetNames)
                obj.files = obj.loadDataset('files', 'aod.util.Parameters');
            end

            % LINKS
            obj.Parent = obj.loadLink('Parent');

            % ATTRIBUTES
            % Special attributes (universal ones mapping to properties)
            specialAttributes = ["UUID", "description", "Class", "EntityType"];
            obj.label = obj.loadAttribute('label');
            obj.UUID = obj.loadAttribute('UUID');
            obj.entityType = aod.core.EntityTypes.init(obj.loadAttribute('EntityType'));
            obj.entityClassName = obj.loadAttribute('Class');

            % Optional special attributes which may not be present
            obj.description = obj.loadAttribute('description');
            obj.Name = obj.loadAttribute('Name');

            % Parse the remaining attributes
            for i = 1:numel(obj.attNames)
                if ~ismember(obj.attNames(i), specialAttributes)
                    obj.parameters(char(obj.attNames(i))) = ...
                        h5readatt(obj.hdfName, obj.hdfPath, obj.attNames(i));
                end
            end
        end
    end

    % Loading methods
    methods (Access = protected)
        function loadInfo(obj)
            % LOADINFO
            %
            % Description:
            %   Load h5info struct and update props accordingly
            %
            % Syntax:
            %   loadInfo(obj)
            %
            % Notes:
            %   Call whenever a change to the underlying HDF5 file is made
            % -------------------------------------------------------------
            info = h5info(obj.hdfName, obj.hdfPath);
            
            if ~isempty(info.Datasets)
                obj.dsetNames = string({info.Datasets.Name});
            else
                obj.dsetNames = [];
            end

            if ~isempty(info.Attributes)
                obj.attNames = string({info.Attributes.Name});
            else
                obj.attNames = [];
            end
            
            if ~isempty(info.Links)
                obj.linkNames = string({info.Links.Name});
            else
                obj.linkNames = [];
            end
        end

        function a = loadAttribute(obj, name)
            % LOADATTRIBUTE
            %
            % Description:
            %   Check if an attribute is present and if so, read it
            %
            % Syntax:
            %   d = loadAttribute(obj, name)
            % -------------------------------------------------------------
            if ~obj.ismember(name, obj.attNames)
                a = [];
                return
            end
            a = h5readatt(obj.hdfName, obj.hdfPath, name);
        end

        function e = loadLink(obj, name)
            % LOADLINK
            %
            % Description:
            %   Check if a link is present and if so, read it
            %
            % Syntax:
            %   d = loadLink(obj, name)
            % -------------------------------------------------------------
            if ~obj.ismember(name, obj.linkNames)
                e = [];
                return
            end
            idx = find(obj.linkNames == name);
            info = h5info(obj.hdfName, obj.hdfPath);
            linkPath = info.Links(idx).Value{1};
            e = obj.factory.create(linkPath);
        end

        function d = loadDataset(obj, name, varargin)
            % LOADDATASET
            %
            % Description:
            %   Check if a dataset is present and if so, read it
            %
            % Syntax:
            %   d = loadDataset(obj, name, varargin)
            % -------------------------------------------------------------
            if ~obj.ismember(name, obj.dsetNames)
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
        function setDatasetsToDynProps(obj)
            % SETDATASETSTODYNPROPS
            %
            % Description:
            %   Creates a dynamic property for all datasets not matching an
            %   existing property of the class
            %
            % Syntax:
            %   setDatasetsToDynProps(obj)
            % -------------------------------------------------------------
            if isempty(obj.dsetNames)
                return
            end

            for i = 1:numel(obj.dsetNames)
                if ~isprop(obj, obj.dsetNames(i))
                    obj.addprop(obj.dsetNames(i));
                    obj.(obj.dsetNames(i)) = aod.h5.readDatasetByType(...
                        obj.hdfName, obj.hdfPath, char(obj.dsetNames(i)));
                end
            end
        end

        function setLinksToDynProps(obj)
            % SETLINKSTODYNPROPS
            %
            % Description:
            %   Creates a dynamic property for all ad hoc links not already
            %   set as an existing property of the class
            %
            % Syntax:
            %   setLinksToDynProps(obj)
            % -------------------------------------------------------------

            if isempty(obj.linkNames)
                return
            end

            for i = 1:numel(obj.linkNames)
                if ~isprop(obj, obj.linkNames(i))
                    obj.(obj.linkNames(i)) = obj.loadLink(obj.linkNames(i));
                end
            end
        end
    end

    methods (Static)
        function tf = ismember(a, b)
            % ISMEMBER
            %
            % Description:
            %   Wrapper for MATLAB's ismember that returns false if the
            %   list to search is empty, instead of an error
            % 
            % Syntax:
            %   tf = ismember(obj)
            % -------------------------------------------------------------
            if isempty(b)
                tf = false;
            else
                tf = ismember(a, b);
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

        function propgrp = getPropertyGroups(obj)
            propgrp = getPropertyGroups@matlab.mixin.CustomDisplay(obj);
            if ~isscalar(obj)
                return
            end

            containerNames = obj.entityType.childContainers();
            if isempty(containerNames)
                return
            end
            for i = 1:numel(containerNames)
                iName = containerNames{i};
                propgrp.PropertyList.(iName) = propgrp.PropertyList.([iName, 'Container']);
                propgrp.PropertyList = rmfield(propgrp.PropertyList, [iName, 'Container']);
            end  % toc = 2.9 ms
        end
    end
end 