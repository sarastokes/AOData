classdef (Abstract) Entity < handle & matlab.mixin.CustomDisplay
% ENTITY
%
% Description:
%   Parent class for all persistent entities read from an HDF5 file
%
% Constructor:
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
        factory
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
            arguments
                obj
                tf              logical = false
            end
            
            obj.readOnly = tf;
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
                hdfPath     char 
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

            [isEntity, isPersisted] = aod.util.isEntity(entity);
            if isEntity
                if isPersisted
                    obj.setLink(propName, entity, propValue);
                else
                    error("AddProperty:UnpersistedLink",...
                        "Links can only be written to persisted entities");
                end
            else
                obj.setDataset(propName, entity, propValue);
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

            p = obj.findprop(propName);
            if isa(p, 'meta.property')
                error('removeProperty:FixedProperty',...
                    'Only dynamic properties can be removed');
            end

            if ismember(propName, obj.dsetNames)
                obj.setDataset(propName, []);
            elseif ismember(propName, obj.linkNames)
                obj.setLink(propName, []);
            else
                error("removeProperty:PropertyDoesNotExist",...
                    "No link/dataset matches %s", propName);
            end

            p = findprop(obj, propName);
            delete(p);
            obj.loadInfo();
        end

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
            evtData = aod.core.persistent.events.GroupEvent(obj, 'Remove');
            notify(obj, 'GroupChanged', evtData);
        end
    end

    % Special property methods
    methods
        function setName(obj, entityName)
            arguments
                obj
                entityName          char        = ''
            end
            obj.Name = entityName;
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

            if isscalar(obj)
                tf = isKey(obj.parameters, paramName);
            else
                tf = arrayfun(@(x) isKey(x.parameters, paramName), obj);
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
                paramName           char
                paramValue
            end

            obj.checkReadOnlyMode();
            
            if ~isscalar(obj)
                arrayfun(@(x) x.setParam(paramName, paramValue), obj);
                return
            end

            evtData = aod.core.persistent.events.AttributeEvent(paramName, paramValue);
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
                arrayfun(@(x) removeParam(x, fileName), obj);
                return
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

            evtData = aod.core.persistent.events.AttributeEvent(obj.hdfPath, paramName);
            notify(obj, 'AttributeChanged', evtData);

            remove(obj.parameters, paramName);

            obj.loadInfo();
        end
    end

    % File methods
    methods
        function tf = hasFile(obj, fileName)
            % HASFILE
            %
            % Description:
            %   Check whether entity has a file
            %
            % Syntax:
            %   tf = hasFile(obj, fileName)
            % -------------------------------------------------------------
            arguments
                obj
                fileName            char
            end

            if isscalar(obj)
                tf = isKey(obj.files, fileName);
            else
                tf = arrayfun(@(x) isKey(x.files, fileName), obj);
            end
        end

        function out = getFile(obj, fileName, errorType)
            % GETFILE
            %
            % Description:
            %   Get file by name
            %
            % Syntax:
            %   out = getFile(obj, fileName, errorType)
            %
            % Notes:
            %   Error type defaults to WARNING for scalar operations and is
            %   restricted to MISSING for nonscalar operations.
            % -------------------------------------------------------------
            arguments
                obj
                fileName            char
                errorType           = aod.util.ErrorTypes.WARNING
            end
            
            import aod.util.ErrorTypes

            if ~isscalar(obj)
                out = arrayfun(@(x) getFile(x, fileName, ErrorTypes.MISSING),...
                    obj, 'UniformOutput', false);
                out = vertcat(out{:});
                return
            end

            if ~obj.hasFile(fileName)
                switch errorType 
                    case ErrorTypes.ERROR
                        error("getFile:FileNotFound",...
                            "File %s not present", fileName);
                    case ErrorTypes.WARNING
                        warning("getFile:FileNotFound",...
                            "File %s not present", fileName);
                        out = [];
                    case ErrorTypes.MISSING
                        out = missing;
                    case ErrorTypes.NONE
                        out = [];
                end
                return
            else
                out = obj.files(fileName);
            end
        end

        function setFile(obj, fileName, fileValue)
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
                fileName            char
                fileValue 
            end

            obj.checkReadOnlyMode();
            
            if ~isscalar(obj)
                arrayfun(@(x) x.setFile(fileName, fileValue), obj);
                return
            end

            evtData = aod.core.persistent.events.FileEvent(fileName, fileValue);
            notify(obj, 'FileChanged', evtData);

            obj.files(fileName) = fileValue;
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

            obj.checkReadOnlyMode();

            if ~isscalar(obj)
                arrayfun(@(x) removeFile(x, fileName), obj);
                return
            end

            if ~obj.hasFile(fileName)
                warning("removeFile:FileNotFound",...
                    "File %s not found in files property!", fileName);
                return
            end

            evtData = aod.core.persistent.events.FileEvent(obj.hdfPath, fileName);
            notify(obj, 'FileChanged', evtData);

            remove(obj.files, fileName);

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

        function addEntity(obj, entity)
            % ADDENTITY
            %
            % Description:
            %   Add a new entity to the persistent hierarchy
            %
            % Syntax:
            %   addEntity(obj, entity)
            % -------------------------------------------------------------
            evtData = aod.core.persistent.events.GroupEvent(entity, 'Add');
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
                    dsetValue = aod.h5.readDatasetByType(...
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

            evtData = aod.core.persistent.events.LinkEvent(linkName, linkValue);
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
                evtData = aod.core.persistent.events.DatasetEvent(dsetName, dsetValue);
            else
                evtData = aod.core.persistent.events.DatasetEvent(...
                    dsetName, dsetValue, obj.(dsetName));
            end
            notify(obj, 'DatasetChanged', evtData);

            if newDset
                %obj.createDynProp(dsetName, 'Dataset');
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