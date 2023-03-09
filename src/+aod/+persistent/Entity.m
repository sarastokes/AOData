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
%   addDataset(obj, propName, propValue)
%   removeDataset(obj, propName)
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
        % Entity metadata that maps to attributes
        parameters              % aod.util.Parameters
        % Files associated with the entity
        files                   % aod.util.Parameters
        % A description of the entity
        description             string
        % Miscellaneous notes about the entity
        notes                   string
    end

    properties (SetAccess = private)
        Parent                  % aod.persistent.Entity
        % A unique identifier for the entity
        UUID                    string
        % When the entity's HDF5 group was last modified
        lastModified            datetime
        % Specification of expected metadata 
        expectedParameters      = aod.util.ParameterManager
    end

    properties (Dependent)
        % Whether the file is in read-only mode or not
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
        % Occurs when "files" property is changed
        FileChanged
        % Occurs when a softlink is added, removed or modified
        LinkChanged
        % Occurs when a group is added or removed
        GroupChanged
        % Occurs when a dataset is added, removed or modified
        DatasetChanged
        % Occurs when an attribute is added, removed or modified
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
            % Toggle read-only mode on and off
            %
            % Syntax:
            %   setReadOnlyMode(obj, tf)
            %
            % Inputs:
            %   tf          read only status (default = true)
            % -------------------------------------------------------------
            arguments
                obj
                tf      {mustBeA(tf, ["logical", "string", "char"])} = true
            end

            if istext(tf)
                if strcmpi(tf, 'on')
                    tf = true;
                elseif strcmpi(tf, 'off')
                    tf = false;
                end
            end
            obj.factory.persistor.setReadOnly(tf);
        end
    end

    % Navigation methods
    methods
        function out = getHomeDirectory(obj)
        
            h = obj.ancestor('Experiment');
            out = h.homeDirectory;
        end

        function h = ancestor(obj, entityType)
            % Recursively search Parent for entity matching entityType
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
            while h.entityType ~= entityType
                h = h.Parent;
                if isempty(h)
                    break
                end
            end
        end

        function e = getByPath(obj, hdfPath)
            % Return any entity within the persistent hierarchy 
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
            % Replace an entity while maintaining the same UUID
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
        function addDataset(obj, propName, propValue)
            % Add a new property (dataset/link) to the entity
            %
            % Syntax:
            %   addDataset(obj, dsetName, dsetValue)
            %
            % TODO: Add system datasets check
            % -------------------------------------------------------------
            arguments
                obj
                propName            char
                propValue           
            end

            obj.verifyReadOnlyMode();

            [isEntity, isPersisted] = aod.util.isEntity(propValue);

            % Make the change in the HDF5 file
            if isEntity
                if isPersisted
                    obj.setLink(propName, propValue);
                else
                    error("addDataset:UnpersistedLink",...
                        "Links can only be written to persisted entities");
                end
            else
                obj.setDataset(propName, propValue);
            end
        end

        function removeDataset(obj, propName)
            % Remove a dataset/link from the entity
            %
            % Syntax:
            %   removeDataset(obj, dsetName)
            % -------------------------------------------------------------
            obj.verifyReadOnlyMode();

            p = findprop(obj, propName);

            if ismember(propName, obj.dsetNames)
                obj.setDataset(propName, []);
            elseif ismember(propName, obj.linkNames)
                obj.setLink(propName, []);
            else
                error("removeDataset:PropertyDoesNotExist",...
                    "No link/dataset matches %s", propName);
            end

            % Make the change in the MATLAB object
            delete(p);
        end
        
    end

    % Special property methods
    methods
        function setName(obj, name)
            % Set, change or clear the entity's name
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
            obj.verifyReadOnlyMode();

            % Make the change in the HDF5 file
            obj.setDataset('Name', obj, name);

            % Make the change in the MATLAB object
            obj.Name = name;
        end

        function setDescription(obj, txt)
            % Set, change or clear the entity's description
            %
            % Syntax:
            %   setDescription(obj, txt)
            % -------------------------------------------------------------
            arguments
                obj
                txt     char = char.empty()
            end
            
            obj.verifyReadOnlyMode();

            % Make the change in the HDF5 file
            obj.setDataset('description', obj, txt);

            % Make the change in the MATLAB object
            obj.description = txt;
        end

        function addNote(obj, newNote)
            arguments
                obj 
                newNote         string
            end

            obj.verifyReadOnlyMode();

            newValue = cat(1, obj.notes, newNote);

            % Make the change in the HDF5 file
            obj.setDataset('notes', newValue);

            % Make the change in the MATLAB object
            obj.notes = newValue;
        end

        function removeNote(obj, noteID)
            arguments
                obj
                noteID      
            end

            if isempty(obj.notes)
                warning('removeNote:NoNotes',...
                    'Entity does not have any notes to remove.');
                return
            end

            if istext(noteID) && strcmpi(noteID, 'all')
                newValue = string.empty();
            elseif isnumeric(noteID)
                mustBeInteger(noteID);
                mustBeInRange(noteID, 1, numel(obj.notes));
                newValue = obj.notes;
                newValue(ID) = [];
            end

            % Make the change in the HDF5 file
            obj.setDataset('notes', newValue);
            
            % Make the change in the MATLAB object
            obj.notes = newValue;
        end
    end

    % Parameter methods
    methods (Sealed)
        function tf = hasParam(obj, paramName)
            % Check whether parameter is present
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
            % Get the value of a parameter by name
            %
            % Syntax:
            %   out = getParam(obj, paramName)
            %   out = getParam(obj, paramName, errorType)
            %
            % Notes:
            %   Error type defaults to WARNING for scalar operations and is
            %   restricted to MISSING for nonscalar operations.
            % -------------------------------------------------------------
            arguments
                obj
                paramName           char 
                errorType           = []
            end

            import aod.util.ErrorTypes

            if isempty(errorType)
                errorType = ErrorTypes.WARNING;
            else
                errorType = ErrorTypes.init(errorType);
            end
            
            if ~isscalar(obj)
                out = aod.util.arrayfun(...
                    @(x) getParam(x, paramName, ErrorTypes.MISSING), obj);

                % Parse missing values
                isMissing = getMissing(out);
                if all(isMissing)
                    error('getParam:NotFound', 'Did not find parameter %s', paramName);
                end

                % Attempt to return a matrix rather than a cell
                if iscell(out) && any(isMissing)
                    out = extractCellData(out);
                end
                return
            end

            if obj.hasParam(paramName)
                out = obj.parameters(paramName);
            else
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
            end
        end

        function setParam(obj, paramName, paramValue)
            % Add new parameter or change the value of existing parameter
            %
            % Syntax:
            %   setParam(obj, paramName, paramValue)
            % -------------------------------------------------------------
            arguments
                obj
                paramName       char
                paramValue                  = []
            end

            obj.verifyReadOnlyMode();
            aod.util.mustNotBeSystemAttribute(paramName)
            
            if ~isscalar(obj)
                arrayfun(@(x) x.setParam(paramName, paramValue), obj);
                return
            end

            % Make the change in the HDF5 file
            obj.setAttribute(paramName, paramValue);
            % Make the change in the MATLAB object
            obj.parameters(paramName) = paramValue;
        end

        function removeParam(obj, paramName)
            % Remove a parameter from the entity
            %
            % Syntax:
            %   removeParam(obj, paramName)
            % -------------------------------------------------------------
            arguments
                obj
                paramName           char
            end

            obj.verifyReadOnlyMode();

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
            % Check whether entity has a file
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
            % Get file by name
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
                fileKey        char 
                errorType       = []
            end

            import aod.util.ErrorTypes
            if isempty(errorType)
                errorType = ErrorTypes.ERROR;
            else
                errorType = ErrorTypes.init(errorType);
            end

            if ~isscalar(obj)
                out = aod.util.arrayfun(...
                    @(x) string(getFile(x, fileKey, ErrorTypes.NONE)), obj);
                out = standardizeMissing(out, "");
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
            % Get file by name with home directory appended
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
                out = arrayfun(@(x) getExptFile(x, fileKey, ErrorTypes.MISSING), obj);
                return
            end

            out = obj.getFile(fileKey, errorType);
            
            if ~isempty(out) || ~ismissing(out)
                out = fullfile(obj.getHomeDirectory(), out);
            end
        end

        function setFile(obj, fileKey, fileValue)
            % Add new file or change the value of existing file
            %
            % Syntax:
            %   setFile(obj, fileName, fileValue)
            % -------------------------------------------------------------
            arguments
                obj
                fileKey            char
                fileValue 
            end

            obj.verifyReadOnlyMode();
            
            if ~isscalar(obj)
                arrayfun(@(x) x.setFile(fileKey, fileValue), obj);
                return
            end

            % Make the change in the HDF5 file
            evtData = aod.persistent.events.FileEvent(fileKey, fileValue);
            notify(obj, 'FileChanged', evtData);

            % Make the change in the MATLAB object
            obj.files(fileKey) = fileValue;
        end

        function removeFile(obj, fileKey)
            % Remove a file from entity's file directory
            %
            % Syntax:
            %   removeFile(obj, fileKey)
            % -------------------------------------------------------------
            arguments
                obj
                fileKey             char
            end

            obj.verifyReadOnlyMode();

            if ~isscalar(obj)
                arrayfun(@(x) removeFile(x, fileKey), obj);
                return
            end

            if ~obj.hasFile(fileKey)
                warning("removeFile:FileNotFound",...
                    "File %s not found in files property!", fileKey);
                return
            end

            % Make the change in the HDF5 file
            evtData = aod.persistent.events.FileEvent(fileKey);
            notify(obj, 'FileChanged', evtData);

            % Make the change in the MATLAB object
            remove(obj.files, fileKey);
            obj.loadInfo();
        end
    end

    % Initialization and creation
    methods (Access = protected)
        function populate(obj)
            % Load datasets and attributes from HDF5, assign pre-defined
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
            
            expectedParams = obj.loadDataset('expectedParameters');
            if ~isempty(expectedParams)
                obj.expectedParameters = expectedParams;
            end

            % LINKS
            obj.Parent = obj.loadLink('Parent');

            % ATTRIBUTES
            % Universial attributes that map to properties, not parameters
            specialAttributes = ["UUID", "Class", "EntityType", "LastModified", "label"];
            obj.label = obj.loadAttribute('label');
            obj.UUID = obj.loadAttribute('UUID');
            obj.entityType = aod.core.EntityTypes.get(obj.loadAttribute('EntityType'));
            obj.entityClassName = obj.loadAttribute('Class');
            lastModTime = obj.loadAttribute('LastModified');
            if ~isempty(lastModTime)
                % TODO Improve datetime!!!
                lastModTime = extractBefore(lastModTime, " (");
                obj.lastModified = datetime(lastModTime, ...
                    'Format', 'dd-MMM-uuuu HH:mm:ss');
            end

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
            % Load h5info struct and update props accordingly
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
            % Check if an attribute is present and if so, read it
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
            % Check if a link is present and if so, read it
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
            % Check if a dataset is present and if so, read it
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
            % Load an entity container
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
            % Add a dynamic property related to an HDF5 link/dataset
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
            % Delete a dynamic property from entity and in HDF5 file
            %
            % Syntax:
            %   deleteDynProp(obj, propName)
            % -------------------------------------------------------------
            p = findprop(obj, propName);
            delete(p);
        end

        function setDatasetsToDynProps(obj)
            % Creates dynamic properties for all undefined datasets
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
            % Create dynamic properties for undefined links
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
        function verifyReadOnlyMode(obj)
            % Throws error if persistent hierarchy is in read only mode
            %
            % Syntax:
            %   verifyReadOnlyMode(obj)
            % -------------------------------------------------------------
            if obj(1).readOnly 
                error("verifyReadOnlyMode:ReadOnlyModeEnabled",...
                    "Disable read only mode before making changes");
            end
        end

        function updateModificationTimestamp(obj)
            % Updates the value of the "LastModified" attribute
            %
            % Syntax:
            %   updateModificationTimestamp(obj)
            % ------------------------------------------------------------- 
            newValue = datetime('now');
            obj.setAttribute('LastModified', newValue);
            obj.lastModified = newValue;
        end

        function setLink(obj, linkName, linkValue)
            % Modify a softlink in entity's HDF5 group
            %
            % Syntax:
            %   setLink(obj, linkName, linkValue)
            % -------------------------------------------------------------
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

            obj.updateModificationTimestamp();
            obj.loadInfo();
        end

        function setDataset(obj, dsetName, dsetValue)
            % Modify a dataset in entity's HDF5 group
            %
            % Syntax:
            %   setDataset(obj, dsetName, dsetValue)
            % -------------------------------------------------------------

            arguments
                obj
                dsetName            char        = ''
                dsetValue                       = []
            end

            % Process based on whether dataset exists or not
            newDset = ~obj.ismember(dsetName, obj.dsetNames);
            if newDset
                evtData = aod.persistent.events.DatasetEvent(dsetName, dsetValue);
            else
                evtData = aod.persistent.events.DatasetEvent(...
                    dsetName, dsetValue, obj.(dsetName));
            end
            notify(obj, 'DatasetChanged', evtData);

            % Make the change in MATLAB object
            if newDset
                obj.addprop(dsetName);
            end
            if isempty(dsetValue)
                obj.deleteDynProp(dsetName);
            else
                obj.(dsetName) = dsetValue;
            end

            obj.updateModificationTimestamp();
            obj.loadInfo();
        end

        function setAttribute(obj, paramName, paramValue)
            % Modify an attribute of the entity's group
            %
            % Notes:
            %   Attributes are used in several locations so updating of 
            %   the MATLAB object needs to occur in the calling function
            % -------------------------------------------------------------

            evtData = aod.persistent.events.AttributeEvent(paramName, paramValue);
            notify(obj, 'AttributeChanged', evtData);

            obj.loadInfo();

            if ~strcmp(paramName, 'LastModified')
                obj.updateModificationTimestamp();
            end
        end
                
        function addEntity(obj, entity)
            % Add a new entity to the persistent hierarchy (back-end)
            %
            % Syntax:
            %   addEntity(obj, entity)
            % -------------------------------------------------------------
            evtData = aod.persistent.events.GroupEvent(entity, 'Add');
            notify(obj, 'GroupChanged', evtData);
        end

        function deleteEntity(obj)
            % Delete this entity
            %
            % Syntax:
            %   deleteEntity(obj)
            % -------------------------------------------------------------
            obj.verifyReadOnlyMode();
            evtData = aod.persistent.events.GroupEvent(obj, 'Remove');
            notify(obj, 'GroupChanged', evtData);
        end

    end

    methods (Static)
        function tf = ismember(a, b)
            % Wraps builtin ismember() and mutes error thrown by empty list
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
            % Defines custom header for display
            if ~isscalar(obj)
                header = getHeader@matlab.mixin.CustomDisplay(obj);
            else
                headerStr = matlab.mixin.CustomDisplay.getClassNameForHeader(obj);
                header = sprintf('%s (%s, %s)\n',... 
                    headerStr, obj.label, char(obj.entityClassName));
            end
        end 

        function propgrp = getPropertyGroups(obj)
            % Defines custom property group for dislay
            propgrp = getPropertyGroups@matlab.mixin.CustomDisplay(obj);
            if ~isscalar(obj)
                return
            end

            containerNames = obj.entityType.childContainers();
            if isempty(containerNames)
                return
            end
            
            % Change container names to the access function names 
            for i = 1:numel(containerNames)
                iName = containerNames{i};
                propgrp.PropertyList.(iName) = propgrp.PropertyList.([iName, 'Container']);
                propgrp.PropertyList = rmfield(propgrp.PropertyList, [iName, 'Container']);
            end  % toc = 2.9 ms
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

end 