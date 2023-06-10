classdef (Abstract) Entity < handle & matlab.mixin.CustomDisplay
% The base class for all AOData persistent objects
%
% Description:
%   Parent class for all persistent entities read from an HDF5 file
%
% Constructor:
%   obj = Entity(hdfName, hdfPath, entityFactory)
%
% Public Methods:
%   setReadOnlyMode(obj, tf)
%   h = getParent(obj, entityType)
%
%   setDescription(obj, txt)
%   setName(obj, txt)
%
%   addDataset(obj, propName, propValue)
%   removeDataset(obj, propName)
%
%   tf = hasAttr(obj, attrName)
%   out = getAttr(obj, attrName)
%   setAttr(obj, attrName, attrValue)
%   removeAttr(obj, attrName)
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
%   AttributeChanged
%   DatasetChanged
%   FileChanged
%   GroupChanged
%   LinkChanged
%   NameChanged

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        % Entity metadata that maps to attributes
        attributes              % aod.common.KeyValueMap
        % Files associated with the entity
        files                   % aod.common.KeyValueMap
        % A description of the entity
        description             string
        % Miscellaneous notes about the entity
        notes                   string
    end

    properties (SetAccess = private)
        Parent                  % aod.persistent.Entity
        % A unique identifier for the entity
        UUID                    string
        % When the entity was first created
        dateCreated             datetime 
        % When the entity's HDF5 group was last modified
        lastModified            datetime
        % Specification of expected metadata 
        expectedAttributes      = aod.util.AttributeManager
        % Specification of expected datasets
        expectedDatasets        = aod.specification.DatasetManager
    end

    properties (Dependent)
        % Whether the file is in read-only mode or not
        readOnly                logical
        % The HDF5 file name
        hdfFileName
    end

    properties (Hidden, Dependent)
        % The entity's HDF5 group name
        groupName
    end

    properties (Hidden, SetAccess = private)
        % Entity properties
        Name                    string
        label                   char 
        entityType
        entityClassName         char      

        % HDF5 properties
        hdfName                 string 
        hdfPath                 char
        linkNames
        dsetNames
        attNames

        % Middle layer between HDF5 file and interface
        factory                 % aod.persistent.EntityFactory
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
        % Occurs when group name is changed
        NameChanged
    end

    methods
        function obj = Entity(hdfName, hdfPath, entityFactory)
            obj.hdfName = hdfName;
            obj.hdfPath = hdfPath;
            obj.factory = entityFactory;

            % Initialize attributes 
            obj.files = aod.common.KeyValueMap();
            obj.attributes = aod.common.KeyValueMap();

            % Create entity from file
            if ~isempty(obj.hdfName)
                obj.populate();
            end
        end

        function value = get.readOnly(obj)
            value = obj.factory.persistor.readOnly;
        end
        
        function value = get.hdfFileName(obj)
            value = obj.factory.hdfName;
        end

        function value = get.groupName(obj)
            value = h5tools.util.getPathEnd(obj.hdfPath);
        end
    end

    % Modification methods
    methods 
        function setReadOnlyMode(obj, tf)
            % Toggle read-only mode on and off
            %
            % Syntax:
            %   setReadOnlyMode(obj, tf)
            %
            % Inputs:
            %   tf          logical (default = true)
            %       Whether changes can be made to underlying HDF5 file 
            % -------------------------------------------------------------
            arguments
                obj
                tf      logical = true
            end

            obj.factory.persistor.setReadOnly(tf);
        end
    end

    % Navigation methods
    methods
        function out = getHomeDirectory(obj)
            % Get home directory from parent Experiment
            %
            % Syntax:
            %   out = getHomeDirectory(obj)
            % -------------------------------------------------------------
        
            h = obj.getParent('Experiment');
            out = h.homeDirectory;
        end

        function getGroupName(obj)
            if ~isscalar(obj)
                out = arrayfun(@(x) string(x.groupName), obj);
                return
            end
            out = obj.groupName;
        end

        function [entity, entityInfo] = query(obj, varargin)
            % Query existing entities throughout the experiment
            %
            % Syntax:
            %   out = query(obj, varargin)
            %
            % Inputs:
            %   See QueryTutorial.md for input information
            % -------------------------------------------------------------

            [entity, entityInfo] = aod.api.QueryManager.go(obj, varargin{:});
        end

        function h = getParent(obj, entityType)
            % Recursively search Parent for entity matching entityType
            %
            % Syntax:
            %   h = getParent(obj, entityType)
            %
            % Examples:
            %   h = obj.getParent(aod.common.EntityTypes.EXPERIMENT)
            %   h = obj.getParent('experiment')
            % -------------------------------------------------------------

            if nargin < 2
                h = obj.Parent;
                return
            end

            entityType = aod.common.EntityTypes.get(entityType);

            h = obj;
            while h.entityType ~= entityType
                h = h.Parent;
                if isempty(h)
                    break
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
        function addDataset(obj, propName, propValue, ignoreValidation)
            % Add a new property (dataset/link) to the entity
            %
            % Syntax:
            %   addDataset(obj, dsetName, dsetValue, ignoreValidation)
            %
            % Inputs:
            %   propName            char
            %       The property's name (HDF5 dataset name)
            %   propValue           
            %       The value of the property 
            %
            % Optional inputs:
            %   ignoreValidation    logical
            %       Whether to write even if the new value fails validation
            % -------------------------------------------------------------
            arguments
                obj
                propName            char
                propValue           
                ignoreValidation    logical = false   
            end

            obj.verifyReadOnlyMode();

            % Check whether the value can be validated with specs
            propSpec = obj.expectedDatasets.get(propName);
            if ~isempty(propSpec)
                isValid = propSpec.validate(propValue);
                if ~isValid 
                    id = 'modifyDataset:InvalidValue';
                    msg = "Value did not pass specs in expectedDatasets. " + ... 
                           "Rerun with ignoreValidation=false to ignore.";
                    if ignoreValidation
                        warning(id, msg);
                    else
                        error(id, msg);
                    end
                end
            end

            [isEntity, isPersisted] = aod.util.isEntity(propValue);

            % Make the change in the HDF5 file
            if isEntity
                if isPersisted
                    obj.modifyLink(propName, propValue);
                else
                    error("addDataset:UnpersistedLink",...
                        "Links can only be written to persisted entities");
                end
            else
                obj.modifyDataset(propName, propValue);
            end
        end

        function setProp(obj, propName, propValue)
        
            arguments
                obj
                propName        char 
                propValue       = []
            end

            obj.verifyReadOnlyMode();

            % Check in expectedDatasets
            p = findprop(obj, propName);
            if ~isempty(p)
                %! check in expectedDatasets
                return
            end
            if ~strcmp(p.SetAccess, 'public')
                error('setProp:SetAccessDenied',...
                    'Property %s does not have public SetAccess', propName);
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

            % Ensure the property exists
            if isempty(p)
                error("removeDataset:PropertyDoesNotExist",...
                    "No link/dataset matches %s", propName);
            end

            % Ensure the property isn't system-defined
            mc = meta.class.fromName("aod.persistent.Entity");
            entityProps = arrayfun(@(x) string(x.Name), mc.PropertyList);
            if ismember(propName, entityProps)
                error("removeDataset:EntityProperty",...
                    "Entity properties cannot be removed, use set methods.");
            end

            % Process as HDF5 link or dataset
            if ismember(propName, obj.dsetNames)
                obj.modifyDataset(propName, []);
            elseif ismember(propName, obj.linkNames)
                obj.modifyLink(propName, []);
            end

            % Note that the dynamic property will not be deleted
        end  
    end

    % Special property methods
    methods
        function setGroupName(obj, name)
            % Change the entity's group name and HDF5 path
            %
            % Syntax:
            %   changeGroupName(obj, name)
            %
            % See also:
            %   aod.persistent.Entity/setName
            % -------------------------------------------------------------
        
            arguments 
                obj 
                name            string
            end
            
            % Don't proceed if name does not need to change
            if strcmp(name, obj.groupName)
                return 
            end

            obj.verifyReadOnlyMode();

            % Ensure new name will be unique
            cohortNames = aod.h5.getEntityGroupCohort(obj);
            if ismember(lower(name), lower(cohortNames))
                error('changeGroupName:NameConflict',...
                    'The name %s matches an existing group in same location', name);
            end
            fprintf('Changing group name from %s to %s\n', obj.groupName, name);

            % answer = aod.app.dialogs.NameChangeDialog()

            evtData = aod.persistent.events.NameEvent(name, obj.Name);
            notify(obj, 'NameChanged', evtData);

            parentPath = h5tools.util.getPathParent(obj.hdfPath);
            obj.changeHdfPath(h5tools.util.buildPath(parentPath, name));

            %! obj.setName(name);
        end

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

            %answer = aod.app.diglogs.NameChangeDialog();

            % Make the change in the HDF5 file
            obj.modifyDataset('Name', name);

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
            obj.modifyDataset('description', obj, txt);

            % Make the change in the MATLAB object
            obj.description = txt;
        end

        function setNote(obj, newNote, ID)
            arguments
                obj 
                newNote         string
                ID              {mustBeInteger} = 0
            end

            obj.verifyReadOnlyMode();

            if ID > 0
                % Replace a specific note
                mustBeInRange(1,numel(obj.notes));
                newValue = obj.notes;
                newValue(ID) = newNote;
            else
                % Append a new note
                newValue = cat(1, obj.notes, newNote);
            end

            % Make the change in the HDF5 file
            obj.modifyDataset('notes', newValue);

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
            obj.modifyDataset('notes', newValue);
            
            % Make the change in the MATLAB object
            obj.notes = newValue;
        end
    end

    % Attribute methods
    methods (Sealed)
        function tf = hasAttr(obj, attrName)
            % Check whether attribute is present
            %
            % Syntax:
            %   tf = hasAttr(obj, attrName)
            % -------------------------------------------------------------
            arguments
                obj
                attrName           char
            end

            if ~isscalar(obj)
                tf = arrayfun(@(x) hasAttr(x, attrName), obj);
                return
            end

            if isempty(obj.attributes)
                tf = false;
            else
                tf = isKey(obj.attributes, attrName);
            end
        end

        function out = getAttr(obj, attrName, errorType)
            % Get the value of a attribute by name
            %
            % Syntax:
            %   out = getAttr(obj, attrName)
            %   out = getAttr(obj, attrName, errorType)
            %
            % Notes:
            %   Error type defaults to WARNING for scalar operations and is
            %   restricted to MISSING for nonscalar operations.
            % -------------------------------------------------------------
            arguments
                obj
                attrName           char 
                errorType           = []
            end

            import aod.infra.ErrorTypes

            if isempty(errorType)
                errorType = ErrorTypes.WARNING;
            else
                errorType = ErrorTypes.init(errorType);
            end
            
            if ~isscalar(obj)
                out = aod.util.arrayfun(...
                    @(x) getAttr(x, attrName, ErrorTypes.MISSING), obj);

                % Parse missing values
                isMissing = getMissing(out);
                if all(isMissing)
                    error('getAttr:NotFound', 'Did not find attribute %s', attrName);
                end

                % Attempt to return a matrix rather than a cell
                if iscell(out) && any(isMissing)
                    out = extractCellData(out);
                end
                return
            end

            if obj.hasAttr(attrName)
                out = obj.attributes(attrName);
            else
                switch errorType 
                    case ErrorTypes.ERROR
                        error("getAttr:AttrNotFound",...
                            "Attribute %s not present", attrName);
                    case ErrorTypes.WARNING
                        warning("getAttr:AttrNotFound",...
                            "Attribute %s not present", attrName);
                        out = [];
                    case ErrorTypes.MISSING
                        out = missing;
                    case ErrorTypes.NONE
                        out = [];
                end
            end
        end

        function setAttr(obj, attrName, attrValue)
            % Add new attribute or change the value of existing attribute
            %
            % Syntax:
            %   setAttr(obj, attrName, attrValue)
            % -------------------------------------------------------------
            arguments
                obj
                attrName       char
                attrValue                  = []
            end

            obj.verifyReadOnlyMode();
            aod.util.mustNotBeSystemAttribute(attrName)
            
            if ~isscalar(obj)
                arrayfun(@(x) x.setAttr(attrName, attrValue), obj);
                return
            end

            % Make the change in the HDF5 file
            obj.setAttribute(attrName, attrValue);
            % Make the change in the MATLAB object
            obj.attributes(attrName) = attrValue;
        end

        function removeAttr(obj, attrName)
            % Remove a attribute from the entity
            %
            % Syntax:
            %   removeAttr(obj, attrName)
            % -------------------------------------------------------------
            arguments
                obj
                attrName           char
            end

            obj.verifyReadOnlyMode();

            if ~isscalar(obj)
                arrayfun(@(x) removeAttr(x, attrName), obj);
                return
            end

            if ismember(attrName, aod.infra.getSystemAttributes())
                warning("setAttr:SystemAttribute",...
                    "Attribute %s not removed, member of system attributes", attrName);
                return
            end
            
            if ~obj.hasAttr(attrName)
                warning("removeAttr:AttrNotFound",...
                    "Attribute %s not found in attributes property!", attrName);
                return
            end

            evtData = aod.persistent.events.AttributeEvent(attrName);
            notify(obj, 'AttributeChanged', evtData);

            remove(obj.attributes, attrName);

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

            import aod.infra.ErrorTypes
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
                errorType           = aod.infra.ErrorTypes.WARNING
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

            % DATASETS -----------
            obj.description = obj.loadDataset('description');
            obj.notes = obj.loadDataset('notes');
            obj.Name = obj.loadDataset('Name');
            obj.files = obj.loadDataset('files', 'aod.common.KeyValueMap');

            expectedAttrs = obj.loadDataset('expectedAttributes');
            if ~isempty(expectedAttrs)
                obj.expectedAttributes = expectedAttrs;
            end

            expectedDsets = obj.loadDataset('expectedDatasets');
            if ~isempty(expectedDsets)
                obj.expectedDatasets = expectedDsets;
            end

            % LINKS -----------
            obj.Parent = obj.loadLink('Parent');

            % ATTRIBUTES -----------
            % Universial attributes that map to properties, not attributes
            specialAttributes = ["UUID", "Class", "EntityType", "lastModified", "dateCreated", "label"];
            obj.label = obj.loadAttribute('label');
            obj.UUID = obj.loadAttribute('UUID');
            obj.entityType = aod.common.EntityTypes.get(obj.loadAttribute('EntityType'));
            obj.entityClassName = obj.loadAttribute('Class');
            lastModTime = obj.loadAttribute('lastModified');
            if ~isempty(lastModTime)
                obj.lastModified = datetime(lastModTime);
            end
            dateCreated = obj.loadAttribute('dateCreated');
            if ~isempty(dateCreated)
                obj.dateCreated = datetime(dateCreated);
            end

            % Parse the remaining attributes
            for i = 1:numel(obj.attNames)
                if ~ismember(obj.attNames(i), specialAttributes)
                    obj.attributes(char(obj.attNames(i))) = ...
                        obj.loadAttribute(obj.attNames(i));
                end
            end

            obj.populateContainers();
        end

        function populateContainers(obj)
            % Implemented by subclasses, if needed
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
            a = h5tools.readatt(obj.hdfName, obj.hdfPath, name);
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
            try
                e = obj.factory.create(linkPath);
            catch ME
                if strcmp(ME.identifier, 'create:InvalidPath')
                    e = aod.h5.BrokenSoftlink(obj, name, linkPath);
                    warning('loadLink:BrokenSoftlink',...
                        'In entity %s, property %s refers to an invalid HDF5 path', ...
                        obj.groupName, name);
                else
                    rethrow(ME);
                end
            end
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
                p = findprop(obj, obj.dsetNames(i));
                if isempty(p)
                    p = obj.addprop(obj.dsetNames(i));
                    propSpec = obj.expectedDatasets.get(obj.dsetNames(i));
                    if isempty(propSpec)
                        p.Description = propSpec.Description;
                    else
                        p.Description = 'Dataset';
                    end
                    dsetValue = aod.h5.read(...
                        obj.hdfName, obj.hdfPath, char(obj.dsetNames(i)));
                    obj.(obj.dsetNames(i)) = dsetValue;
                elseif isa(p, 'meta.DynamicProperty')
                    dsetValue = aod.h5.read(...
                        obj.hdfName, obj.hdfPath, char(obj.dsetNames(i)));
                    obj.(obj.dsetNames(i)) = dsetValue;
                end
            end

            if isempty(obj.expectedDatasets)
                return
            end

            emptyDsets = setdiff(obj.expectedDatasets.list, obj.dsetNames);
            for i = 1:numel(emptyDsets)
                p = findprop(obj, emptyDsets(i));
                if isempty(p)
                    p = obj.addprop(emptyDsets(i));
                    propSpec = obj.expectedDatasets.get(emptyDsets(i));
                    p.Description = propSpec.Description.Value;
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
                p = findprop(obj, obj.linkNames(i));
                if isempty(p)
                    % Create new dynamic property
                    p = obj.addprop(obj.linkNames(i));
                    p.Description = 'Link';
                    linkValue = obj.loadLink(obj.linkNames(i));
                    obj.(obj.linkNames(i)) = linkValue;
                elseif isa(p, 'meta.DynamicProperty')
                    % Update existing dynamic property
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
            % Updates the value of the "lastModified" attribute
            %
            % Syntax:
            %   updateModificationTimestamp(obj)
            % ------------------------------------------------------------- 
            newValue = datetime('now');
            obj.setAttribute('lastModified', newValue);
            obj.lastModified = newValue;
        end

        function modifyLink(obj, linkName, linkValue)
            % Modify a softlink in entity's HDF5 group
            %
            % Syntax:
            %   modifyLink(obj, linkName, linkValue)
            % -------------------------------------------------------------
            arguments
                obj
                linkName            char
                linkValue           = []
            end

            evtData = aod.persistent.events.LinkEvent(linkName, linkValue);
            notify(obj, 'LinkChanged', evtData);

            if ~ismember(linkName, obj.linkNames)
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

        function modifyDataset(obj, dsetName, dsetValue)
            % Modify a dataset in entity's HDF5 group
            %
            % Syntax:
            %   modifyDataset(obj, dsetName, dsetValue)
            % -------------------------------------------------------------

            arguments
                obj
                dsetName            char        
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

        function setAttribute(obj, attrName, attrValue)
            % Modify an attribute of the entity's group
            %
            % Notes:
            %   Attributes are used in several locations so updating of 
            %   the MATLAB object needs to occur in the calling function
            % -------------------------------------------------------------

            evtData = aod.persistent.events.AttributeEvent(attrName, attrValue);
            notify(obj, 'AttributeChanged', evtData);

            obj.loadInfo();

            if ~strcmp(attrName, 'lastModified')
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
    end

    methods
        function deleteEntity(obj)
            % Delete this entity
            %
            % Syntax:
            %   deleteEntity(obj)
            % -------------------------------------------------------------
            obj.verifyReadOnlyMode();

            evtData = aod.persistent.events.GroupEvent(obj, 'Remove');
            notify(obj, 'GroupChanged', evtData);

            delete(obj);
        end
    end

    methods (Access = private)
        function validateGroupNames(obj, groupName)
            
        end
    end

    methods (Access = {?aod.persistent.EntityFactory})
        function changeHdfPath(obj, newPath)
            obj.hdfPath = newPath;
            obj.populateContainers();
        end

        function reload(obj)
            obj.populate();
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
            if ~isscalar(obj) || isempty(obj)
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