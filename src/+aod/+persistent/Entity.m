classdef (Abstract) Entity < handle & matlab.mixin.CustomDisplay
% ENTITY
%
% Description:
%   Parent class for all persistent entities read from an HDF5 file
%
% Constructor:
%   obj = Entity(hdfName, hdfPath, entityFactory)
%
% Public Methods:
%   setReadOnlyMode(obj, tf)
%   h = ancestor(obj, entityType)
%   e = getByPath(obj, hdfPath)
%
%   setDescription(obj, txt)
%   setName(obj, txt)
%
%   addProperty(obj, propName, propValue)
%   removeProperty(obj, propName)
%
%   tf = hasParam(obj, paramName)
%   out = getParam(obj, paramName)
%   setParam(obj, paramName, paramValue)
%   removeParam(obj, paramName)
%
%   tf = hasFile(obj, fileKey)
%   out = getFile(obj, fileKey)
%   out = getExptFile(obj, fileKey)
%   setFile(obj, fileKey, fileValue)
%   removeFile(obj, fileKey)
%
%   tf = isequal(obj, entity)
%   
% Events:
%   FileChanged
%   LinkChanged
%   GroupChanged
%   DatasetChanged
%   AttributeChanged

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        parameters              % aod.util.Parameters
        files                   % aod.util.Parameters
        description             string
        notes                   string
    end

    properties (SetAccess = private)
        Parent                  % aod.persistent.Entity
        UUID                    string
        lastModified             datetime
    end

    properties (Dependent)
        readOnly
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
        factory                 % aod.persistent.EntityFactory
    end

    properties (Access = private)
        isInitializing
    end

    events 
        FileChanged
        LinkChanged
        GroupChanged
        DatasetChanged
        AttributeChanged
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
            obj.isInitializing = true;
            if ~isempty(obj.hdfName)
                obj.populate();
            end
            obj.isInitializing = false;
        end

        function value = get.readOnly(obj)
            value = obj.factory.persistor.readOnly;
        end

        function setReadOnlyMode(obj, tf)
            % SETREADONLYMODE
            %
            % Description:
            %   Toggle read-only mode on and off
            %
            % Syntax:
            %   setReadOnlyMode(obj, tf)
            %
            % Inputs:
            %   tf          read only status (default = true)
            % -------------------------------------------------------------
            arguments
                obj
                tf              logical = true
            end
            
            obj.factory.persistor.setReadOnly(tf);
        end
    end

    % Overloaded MATLAB methods
    methods
        function tf = isequal(obj, entity)
            % Tests whether the UUIDs of two entities are equal
            %
            % Syntax:
            %   tf = isequal(obj, entity)
            % -------------------------------------------------------------
            
            arguments
                obj
                entity      {mustBeA(entity, 'aod.persistent.Entity')}
            end
            tf = isequal(obj.UUID, entity.UUID);
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
            try
                entityType = aod.core.EntityTypes.get(entityType);
            catch
                entityType = aod.core.EntityTypes.init(entityType);
            end

            h = obj;
            while h.entityType ~= entityType
                h = h.Parent;
                if isempty(h)
                    break
                end
            end
        end

        function e = getByPath(obj, hdfPath)
            % GETBYPATH
            %
            % Description:
            %   Return any entity within the persistent hierarchy 
            %
            % Syntax:
            %   e = getByPath(obj, hdfPath)
            %
            % Notes:
            %   Returns empty with a warning if hdfPath not found
            % -------------------------------------------------------------
            arguments
                obj
                hdfPath     string 
            end

            try
                e = obj.factory.create(hdfPath);
            catch ME
                if strcmp(ME.identifier, 'create:InvalidPath')
                    warning('getByPath:InvalidHdfPath',...
                        'HDF path not found: %s', hdfPath);
                    e = [];
                else
                    rethrow(ME);
                end
            end
        end
    end

    % Entity methods
    methods
        function replaceEntity(obj, newEntity)
            % REPLACEENTITY
            %
            % Description:
            %   Replace an entity
            %
            % Syntax:
            %   replaceEntity(obj, newEntity)
            % -------------------------------------------------------------
            arguments
                obj
                newEntity       {mustBeA(newEntity, 'aod.core.Entity')}
            end
            
            evtData = aod.persistent.events.GroupEvent(newEntity, 'Replace', obj);
            notify(obj, 'GroupChanged', evtData);
        end
    end

    % Dataset methods
    methods
        function addProperty(obj, propName, propValue)
            % ADDDATASET
            %
            % Description:
            %   Add a new property (dataset/link) to the entity
            %
            % Syntax:
            %   addDataset(obj, dsetName, dsetValue)
            %
            % TODO: Add standard attributes
            % -------------------------------------------------------------
            arguments
                obj
                propName            char
                propValue           
            end

            obj.checkReadOnlyMode();

            [isEntity, isPersisted] = aod.util.isEntity(propValue);
            if isEntity
                if isPersisted
                    obj.setLink(propName, propValue);
                else
                    error("AddProperty:UnpersistedLink",...
                        "Links can only be written to persisted entities");
                end
            else
                obj.setDataset(propName, propValue);
            end
        end

        function removeProperty(obj, propName)
            % REMOVEPROPERTY
            %
            % Description:
            %   Remove a dataset/link from the entity
            %
            % Syntax:
            %   remove(obj, dsetName)
            % -------------------------------------------------------------
            obj.checkReadOnlyMode();

            p = findprop(obj, propName);

            if ismember(propName, obj.dsetNames)
                obj.setDataset(propName, []);
            elseif ismember(propName, obj.linkNames)
                obj.setLink(propName, []);
            else
                error("removeProperty:PropertyDoesNotExist",...
                    "No link/dataset matches %s", propName);
            end

            delete(p);
            obj.loadInfo();
        end
        
    end

    % Special property methods
    methods
        function setName(obj, name)
            % SETNAME
            %
            % Description:
            %   Set, change or remove the entity's name
            %
            % Syntax:
            %   setName(obj, name)
            %
            % Notes:
            %   This will not change the entity group name
            % -------------------------------------------------------------
            arguments
                obj
                name                char        = ''
            end
            obj.checkReadOnlyMode();
            obj.setDataset('Name', obj, name);
            obj.Name = name;
        end

        function setDescription(obj, txt)
            % SETDESCRIPTION
            %
            % Description:
            %   Set, change or remove the entity's description
            %
            % Syntax:
            %   setDescription(obj, txt)
            % -------------------------------------------------------------
            arguments
                obj
                txt     char = []
            end
            
            obj.checkReadOnlyMode();
            obj.setDataset('description', obj, txt);
            obj.description = txt;
        end
    end

    % Parameter methods
    methods (Sealed)
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

            if ~isscalar(obj)
                tf = arrayfun(@(x) hasParam(x, paramName), obj);
                return
            end

            if isempty(obj.parameters)
                tf = false;
            else
                tf = isKey(obj.parameters, paramName);
            end
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
            %
            % Notes:
            %   Error type defaults to WARNING for scalar operations and is
            %   restricted to MISSING for nonscalar operations.
            % -------------------------------------------------------------
            import aod.util.ErrorTypes
            if nargin < 3
                errorType = ErrorTypes.WARNING;
            end
            
            if ~isscalar(obj)
                out = arrayfun(@(x) getParam(x, paramName, ErrorTypes.MISSING),...
                    obj, 'UniformOutput', false);
                out = vertcat(out{:});
                return
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
                    case ErrorTypes.MISSING
                        out = missing;
                    case ErrorTypes.NONE
                        out = [];
                end
                return
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
                paramName       {aod.util.mustNotBeSystemAttribute(paramName)}
                paramValue      = []
            end

            obj.checkReadOnlyMode();
            
            if ~isscalar(obj)
                arrayfun(@(x) x.setParam(paramName, paramValue), obj);
                return
            end

            evtData = aod.persistent.events.AttributeEvent(paramName, paramValue);
            notify(obj, 'AttributeChanged', evtData);

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

            obj.checkReadOnlyMode();

            if ~isscalar(obj)
                arrayfun(@(x) removeParam(x, paramName), obj);
                return
            end

            if ismember(paramName, aod.h5.getSystemAttributes())
                warning("setParam:SystemAttribute",...
                    "Parameter %s not removed, member of system attributes", paramName);
                return
            end
            
            if ~obj.hasParam(paramName)
                warning("removeParam:ParamNotFound",...
                    "Parameter %s not found in parameters property!", paramName);
                return
            end

            evtData = aod.persistent.events.AttributeEvent(paramName);
            notify(obj, 'AttributeChanged', evtData);

            remove(obj.parameters, paramName);

            obj.loadInfo();
        end
    end

    % File methods
    methods (Sealed)
        function tf = hasFile(obj, fileKey)
            % HASFILE
            %
            % Description:
            %   Check whether entity has a file
            %
            % Syntax:
            %   tf = hasFile(obj, fileKey)
            % -------------------------------------------------------------
            arguments
                obj
                fileKey             char
            end

            if ~isscalar(obj)
                tf = arrayfun(@(x) hasFile(x, fileKey), obj);
                return
            end
            if isempty(obj.files)
                tf = false;
            else
                tf = isKey(obj.files, fileKey);
            end
        end

        function out = getFile(obj, fileKey, errorType)
            % GETFILE
            %
            % Description:
            %   Get file by name
            %
            % Syntax:
            %   out = getFile(obj, fileKey, errorType)
            %
            % Notes:
            %   Error type defaults to WARNING for scalar operations and is
            %   restricted to MISSING for nonscalar operations.
            % -------------------------------------------------------------
            arguments
                obj
                fileKey             char
                errorType           = aod.util.ErrorTypes.WARNING
            end
            
            import aod.util.ErrorTypes

            if ~isscalar(obj)
                out = arrayfun(@(x) getFile(x, fileKey, ErrorTypes.MISSING),...
                    obj, 'UniformOutput', false);
                out = vertcat(out{:});
                return
            end

            if ~obj.hasFile(fileKey)
                switch errorType 
                    case ErrorTypes.ERROR
                        error("getFile:FileNotFound",...
                            "File %s not present", fileKey);
                    case ErrorTypes.WARNING
                        warning("getFile:FileNotFound",...
                            "File %s not present", fileKey);
                        out = [];
                    case ErrorTypes.MISSING
                        out = missing;
                    case ErrorTypes.NONE
                        out = [];
                end
                return
            else
                out = obj.files(fileKey);
            end
        end

        function out = getExptFile(obj, fileKey, errorType)
            % GETEXPTFILE
            %
            % Description:
            %   Return file name with home directory appended
            %
            % Syntax:
            %   out = getExptFile(obj, fileKey, errorType)
            %
            % See getFile() for information on inputs
            % -------------------------------------------------------------
            arguments
                obj
                fileKey             char
                errorType           = aod.util.ErrorTypes.WARNING
            end

            if ~isscalar(obj)
                out = arrayfun(@(x) getExptFile(x, fileKey, ErrorTypes.MISSING),...
                    obj, 'UniformOutput', false);
                out = vertcat(out{:});
                return
            end

            out = obj.getFile(fileKey, errorType);
            
            h = obj.ancestor('Experiment');
            out = fullfile(h.homeDirectory, out);
        end

        function setFile(obj, fileKey, fileValue)
            % SETFILE
            %
            % Description:
            %   Add new file or change value of existing file
            %
            % Syntax:
            %   setFile(obj, fileName, fileValue)
            % -------------------------------------------------------------
            arguments
                obj
                fileKey            char
                fileValue 
            end

            obj.checkReadOnlyMode();
            
            if ~isscalar(obj)
                arrayfun(@(x) x.setFile(fileKey, fileValue), obj);
                return
            end

            evtData = aod.persistent.events.FileEvent(fileKey, fileValue);
            notify(obj, 'FileChanged', evtData);

            obj.files(fileKey) = fileValue;
        end

        function removeFile(obj, fileKey)
            % REMOVEFILE
            %
            % Description:
            %   Remove a file from entity's file directory
            %
            % Syntax:
            %   removeFile(obj, fileKey)
            % -------------------------------------------------------------
            arguments
                obj
                fileKey             char
            end

            obj.checkReadOnlyMode();

            if ~isscalar(obj)
                arrayfun(@(x) removeFile(x, fileKey), obj);
                return
            end

            if ~obj.hasFile(fileKey)
                warning("removeFile:FileNotFound",...
                    "File %s not found in files property!", fileKey);
                return
            end

            evtData = aod.persistent.events.FileEvent(fileKey);
            notify(obj, 'FileChanged', evtData);

            remove(obj.files, fileKey);

            obj.loadInfo();
        end
    end

    % Initialization and creation
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
            obj.description = obj.loadDataset('description');
            obj.notes = obj.loadDataset('notes');
            obj.Name = obj.loadDataset('Name');
            obj.files = obj.loadDataset('files', 'aod.util.Parameters');

            % LINKS
            obj.Parent = obj.loadLink('Parent');

            % ATTRIBUTES
            % Universial attributes that map to properties, not parameters
            specialAttributes = ["UUID", "Class", "EntityType", "LastModified"];
            obj.label = obj.loadAttribute('label');
            obj.UUID = obj.loadAttribute('UUID');
            obj.entityType = aod.core.EntityTypes.init(obj.loadAttribute('EntityType'));
            obj.entityClassName = obj.loadAttribute('Class');
            obj.lastModified = datetime(obj.loadAttribute('LastModified'),... 
                'Format', 'dd-MMM-uuuu HH:mm:ss');

            % Parse the remaining attributes
            for i = 1:numel(obj.attNames)
                if ~ismember(obj.attNames(i), specialAttributes)
                    obj.parameters(char(obj.attNames(i))) = ...
                        h5readatt(obj.hdfName, obj.hdfPath, obj.attNames(i));
                end
            end
        end

        function addEntity(obj, entity)
            % ADDENTITY
            %
            % Description:
            %   Add a new entity to the persistent hierarchy
            %
            % Syntax:
            %   addEntity(obj, entity)
            % -------------------------------------------------------------
            evtData = aod.persistent.events.GroupEvent(entity, 'Add');
            notify(obj, 'GroupChanged', evtData);
        end
    end

    methods (Access = protected)
        function deleteEntity(obj)
            % DELETEENTITY
            %
            % Description:
            %   Delete the entity
            %
            % Syntax:
            %   deleteEntity(obj)
            % -------------------------------------------------------------
            obj.checkReadOnlyMode();
            evtData = aod.persistent.events.GroupEvent(obj, 'Remove');
            notify(obj, 'GroupChanged', evtData);
        end

        function checkReadOnlyMode(obj)
            % CHECKREADONLYMODE
            %
            % Description:
            %   Throws error if persistent hierarchy is in read only mode
            %
            % Syntax:
            %   checkReadOnlyMode(obj)
            % -------------------------------------------------------------
            if obj(1).readOnly 
                error("Entity:ReadOnlyModeEnabled",...
                    "Disable read only mode before making changes");
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
            d = aod.h5.read(obj.hdfName, obj.hdfPath, name, varargin{:});
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
            c = aod.persistent.EntityContainer(...
                h5tools.util.buildPath(obj.hdfPath, containerName), obj.factory);
        end
    end

    % Dynamic property methods
    methods (Access = protected)
        function p = createDynProp(obj, propName, propType, propValue)
            % CREATEDYNPROP
            % 
            % Description:
            %   Add a dynamic property related to an HDF5 link/dataset
            %
            % Syntax:
            %   p = createDynProp(obj, propName, propType)
            % -------------------------------------------------------------
            arguments
                obj
                propName            char
                propType            {mustBeMember(propType, {'Link', 'Dataset'})}
                propValue           = []'
            end

            p = obj.addprop(propName);
            switch propType
                case 'Link'
                    obj.setLink(propName, propValue)
                case 'Dataset'
                    p.SetMethod = @obj.setDataset;
            end
        end

        function deleteDynProp(obj, propName)
            % DELETEDYNPROP
            %
            % Description:
            %   Delete a dynamic property from entity and in HDF5 file
            %
            % Syntax:
            %   deleteDynProp(obj, propName)
            % -------------------------------------------------------------
            p = findprop(obj, propName);
            delete(p);
        end

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
                    p = obj.addprop(obj.dsetNames(i));
                    p.Description = 'Dataset';
                    dsetValue = aod.h5.read(...
                        obj.hdfName, obj.hdfPath, char(obj.dsetNames(i)));
                    obj.(obj.dsetNames(i)) = dsetValue;
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
                    p = obj.addprop(obj.linkNames(i));
                    p.Description = 'Link';
                    linkValue = obj.loadLink(obj.linkNames(i));
                    obj.(obj.linkNames(i)) = linkValue;
                end
            end
        end
    end

    % HDF5 edit methods
    methods (Access = protected)
        function setLink(obj, linkName, linkValue)
            arguments
                obj
                linkName            char
                linkValue           = []
            end

            evtData = aod.persistent.events.LinkEvent(linkName, linkValue);
            notify(obj, 'LinkChanged', evtData);

            if ~ismember(linkName, obj.linkNames)
                %obj.createDynProp(linkName, 'Link');
                h = obj.addprop(linkName);
                h.Description = 'Link';
            end
            if isempty(linkValue)
                obj.deleteDynProp(linkName);
            else
                obj.(linkName) = obj.loadLink(linkName);
            end
            obj.loadInfo()
        end

        function setDataset(obj, dsetName, dsetValue)
            arguments
                obj
                dsetName            char        = ''
                dsetValue                       = []
            end

            newDset = ~obj.ismember(dsetName, obj.dsetNames);
            if newDset
                evtData = aod.persistent.events.DatasetEvent(dsetName, dsetValue);
            else
                evtData = aod.persistent.events.DatasetEvent(...
                    dsetName, dsetValue, obj.(dsetName));
            end
            notify(obj, 'DatasetChanged', evtData);

            if newDset
                obj.addprop(dsetName);
            end
            if isempty(dsetValue)
                obj.deleteDynProp(dsetName);
            else
                obj.(dsetName) = dsetValue;
            end
            obj.loadInfo();
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