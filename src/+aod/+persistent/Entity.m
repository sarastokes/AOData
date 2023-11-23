classdef (Abstract) Entity < handle & matlab.mixin.CustomDisplay & aod.common.mixins.Entity
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
%   addProp(obj, propName, propValue)
%   setProp(obj, propName, propValue)
%   removeProp(obj, propName)
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
        Schema                  % aod.persistent.Schema
        % A unique identifier for the entity
        UUID                    string
        % When the entity was first created
        dateCreated             datetime
        % When the entity's HDF5 group was last modified
        lastModified            datetime
        % The underlying HDF5 file
        hdfName                 string
        % The core class name used to create the entity
        coreClassName           char
    end

    properties (Dependent)
        % Whether the file is in read-only mode or not
        readOnly                logical
    end

    properties (Hidden, Dependent)
        % The entity's HDF5 group name
        groupName               char
    end

    properties (Hidden, SetAccess = private)
        % Entity properties
        Name                    string
        label                   string
        entityType              % aod.common.EntityTypes
        classUUID               string
        % The entity's HDF5 path
        hdfPath                 char
        % Middle layer between HDF5 file and interface
        factory                 % aod.persistent.EntityFactory
    end

    properties (Access = {?aod.persistent.Entity, ?aod.app.viewer.ExperimentPresenter})
        linkNames
        dsetNames
        attNames
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

            % Confirm entity types match
            if ~isequal(newEntity.entityType, obj.entityType)
                error('replaceEntity:InvalidEntityType',...
                    'Entity types must match');
            end

            % Rename if necessary
            if ~strcmp(newEntity.groupName, obj.groupName)
                obj.setGroupName(newEntity.groupName);
            end

            % Send to Persistor to perform HDF5 actions outside interface
            % Includes updating specifications and entity's attr properties
            evtData = aod.persistent.events.GroupEvent(obj, 'Replace', newEntity);
            notify(obj, 'GroupChanged', evtData);

            [propsToAdd, propsToRemove, propsToChange] = obj.compareDatasets(obj, newEntity);
            for i = 1:numel(propsToAdd)
                obj.addProp(propsToAdd(i), newEntity.(propsToAdd(i)));
            end

            for i = 1:numel(propsToRemove)
                obj.removeProp(propsToRemove(i));
            end

            for i = 1:numel(propsToChange)
                obj.setProp(propsToChange(i), newEntity.(propsToChange(i)));
            end
        end
    end

    % Dataset methods
    methods
        function addProp(obj, propName, propValue)
            % Add a new property (dataset/link) to the entity
            %
            % Syntax:
            %   addProp(obj, dsetName, dsetValue, ignoreValidation)
            %
            % Inputs:
            %   propName            char
            %       The property's name (HDF5 dataset name)
            %   propValue
            %       The value of the property
            % -------------------------------------------------------------
            arguments
                obj
                propName            char
                propValue           = []
            end

            % Confirm this is a new property
            p = findprop(obj, propName);
            if ~isempty(p)
                if ismember(lower(propName), lower(aod.util.getAllPropNames(obj)))
                    error('addProp:DatasetExist',...
                        'Property %s exists, use setProp', propName);
                end
            end

            obj.verifyReadOnlyMode();

            % Make the change in the HDF5 file
            [isEntity, isPersisted] = aod.util.isEntity(propValue);
            if isEntity
                if isPersisted
                    obj.modifyLink(propName, propValue);
                else
                    error("addProp:UnpersistedLink",...
                        "Links can only be written to persisted entities");
                end
            else
                obj.modifyDataset(propName, propValue);
            end
        end

        function setProp(obj, propName, propValue, ignoreValidation)
            % Set the value of a property
            %
            % Syntax:
            %   setProp(obj, propName, propValue)
            %   setProp(obj, propName, propValue, ignoreValidation)
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
                propValue                   = []
                ignoreValidation    logical = false
            end

            obj.verifyReadOnlyMode();

            % Check whether the value can be validated with specs
            propSpec = obj.Schema.Datasets.get(propName);
            if ~isempty(propSpec)
                [isValid, ME] = propSpec.validate(propValue);
                if ~isValid
                    % TODO Update for new schema format
                    id = 'modifyDataset:InvalidValue';
                    msg = "Value did not pass specs in Schema. " + ...
                           "Rerun with ignoreValidation=false to ignore.";
                    if ignoreValidation
                        warning(id, msg);
                    else
                        error(id, msg);
                    end
                end
            end

            % Make the change in the HDF5 file
            [isEntity, isPersisted] = aod.util.isEntity(propValue);
            if isEntity
                if isPersisted
                    obj.modifyLink(propName, propValue);
                else
                    error("setProp:UnpersistedLink",...
                        "Links can only be written to persisted entities");
                end
            else
                obj.modifyDataset(propName, propValue);
            end
        end

        function removeProp(obj, propName)
            % Remove a dataset/link from the entity
            %
            % Syntax:
            %   removeProp(obj, dsetName)
            %
            % Note:
            %   The property will not be removed if in dataset schemas
            % -------------------------------------------------------------
            obj.verifyReadOnlyMode();

            p = findprop(obj, propName);

            % Ensure the property exists
            if isempty(p)
                error("removeProp:PropertyDoesNotExist",...
                    "No link/dataset matches %s", propName);
            end

            % Ensure the property isn't system-defined
            mc = meta.class.fromName("aod.persistent.Entity");
            entityProps = arrayfun(@(x) string(x.Name), mc.PropertyList);
            if ismember(propName, entityProps)
                error("removeProp:EntityProperty",...
                    "Entity properties cannot be removed, use set methods.");
            end

            % Process as HDF5 link or dataset
            if ismember(propName, obj.dsetNames)
                obj.modifyDataset(propName, []);
            elseif ismember(propName, obj.linkNames)
                obj.modifyLink(propName, []);
            end

            % Delete if not in schema
            if ~obj.Schema.Datasets.has(propName)
                delete(p);
            end
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
            % Add a note or replace an existing note
            %
            % Syntax:
            %   setNote(obj, newNote, ID)
            % -------------------------------------------------------------
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

            obj.verifyReadOnlyMode();

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
        function setAttr(obj, attrName, attrValue)
            % Add new attribute or change the value of existing attribute
            %
            % Syntax:
            %   setAttr(obj, attrName, attrValue)
            %
            % TODO: Validation?
            % -------------------------------------------------------------
            arguments
                obj
                attrName            char
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

            % LINKS -----------
            obj.Parent = obj.loadLink('Parent');

            % ATTRIBUTES -----------
            % Universial attributes that map to properties, not attributes
            specialAttributes = ["UUID", "Class", "EntityType", "lastModified", "dateCreated", "label"];
            obj.label = obj.loadAttribute('label');
            obj.UUID = obj.loadAttribute('UUID');
            obj.classUUID = obj.loadAttribute('ClassUUID');
            obj.entityType = aod.common.EntityTypes.get(obj.loadAttribute('EntityType'));
            obj.coreClassName = obj.loadAttribute('Class');
            obj.assignAttributeToProp('dateCreated');
            obj.assignAttributeToProp('lastModified');

            % SCHEMA (must be loaded after entity info populated)
            obj.Schema = aod.persistent.Schema(obj);

            % Parse the remaining attributes
            for i = 1:numel(obj.attNames)
                if ~ismember(obj.attNames(i), specialAttributes)
                    obj.attributes(char(obj.attNames(i))) = ...
                        obj.loadAttribute(obj.attNames(i));
                end
            end

            obj.populateContainers();
        end

        function populateContainers(~)
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

        function assignProp(obj, dsetName, varargin)
            % Load dataset and assign property if valid
            %
            % Description:
            %   This intermediate step prevents assignment of empty values
            %   to properties with data type specifications that do not
            %   accept generic [] inputs (ugh datetime)
            % -----------------------------------------------------------
            d = obj.loadDataset(dsetName, varargin{:});
            if ~isempty(d)
                obj.(dsetName) = d;
            end
        end

        function assignLinkProp(obj, linkName, propName)
            % Assign a link to a property, if not empty
            if nargin < 3
                propName = linkName;
            end

            l = obj.loadLink(linkName);
            if ~isempty(l)
                obj.(propName) = l;
            end
        end

        function assignAttributeToProp(obj, hdfAttrName, propName)
            % Assign an attribute to a property, if not empty
            if nargin < 3
                propName = hdfAttrName;
            end
            a = obj.loadAttribute(hdfAttrName);
            if ~isempty(a)
                obj.(propName) = a;
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

        function populateDatasetsAsDynProps(obj)
            % Creates dynamic properties for all undefined datasets
            %
            % Description:
            %   Creates a dynamic property for all datasets not matching an
            %   existing property of the class
            %
            % Syntax:
            %   populateDatasetsAsDynProps(obj)
            % -------------------------------------------------------------
            if isempty(obj.dsetNames)
                return
            end

            for i = 1:numel(obj.dsetNames)
                p = findprop(obj, obj.dsetNames(i));
                if isempty(p)
                    p = obj.addprop(obj.dsetNames(i));
                    dsetValue = aod.h5.read(...
                        obj.hdfName, obj.hdfPath, char(obj.dsetNames(i)));
                    obj.(obj.dsetNames(i)) = dsetValue;
                    % Check specifications
                    propSpec = obj.Schema.Datasets.get(obj.dsetNames(i));
                    if ~isempty(propSpec)
                        p.Description = propSpec.Primitive.Description.Value;
                        % Final step, after setting the value
                        p.SetAccess = 'protected';
                    end
                elseif isa(p, 'meta.DynamicProperty')
                    dsetValue = aod.h5.read(...
                        obj.hdfName, obj.hdfPath, char(obj.dsetNames(i)));
                    p.SetAccess = 'public';
                    obj.(obj.dsetNames(i)) = dsetValue;
                    p.SetAccess = 'protected';
                end
            end

            if obj.Schema.Datasets.Count == 0
                return
            end

            emptyDsets = setdiff(obj.Schema.Datasets.list(), obj.dsetNames);
            for i = 1:numel(emptyDsets)
                p = findprop(obj, emptyDsets(i));
                if isempty(p)
                    p = obj.addprop(emptyDsets(i));
                    % Check specifications
                    propSpec = obj.Schema.Datasets.get(emptyDsets(i));
                    if ~isempty(propSpec)
                        % TODO p.Description = propSpec.Description.Value;
                        p.SetAccess = 'protected';
                    end
                end
            end
        end

        function populateLinksAsDynProps(obj)
            % Create dynamic properties for undefined links
            %
            % Description:
            %   Creates a dynamic property for all ad hoc links not already
            %   set as an existing property of the class
            %
            % Syntax:
            %   populateLinksAsDynProps(obj)
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
                    p.SetAccess = 'protected';
                elseif isa(p, 'meta.DynamicProperty')
                    % Update existing dynamic property
                    linkValue = obj.loadLink(obj.linkNames(i));
                    p.SetAccess = 'public';
                    obj.(obj.linkNames(i)) = linkValue;
                    p.SetAccess = 'protected';
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
                obj.assignLinkProp(linkName);
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
            obj.dissociateEntity()
        end
    end

    methods (Access = private)
        function validateGroupNames(obj, groupName) %#ok

        end
    end

    methods (Access = {?aod.common.mixins.Entity})
        function dissociateEntity(obj, entity)

            if ~isscalar(entity)
                arrayfun(@(x) dissociateEntity(obj, x), x);
                return
            end

            evtData = aod.persistent.events.GroupEvent(obj, 'Remove');
            notify(obj, 'GroupChanged', evtData);

            delete(obj);
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
                    headerStr, obj.label, char(obj.coreClassName));
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
end