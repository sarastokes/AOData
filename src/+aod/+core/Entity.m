classdef (Abstract) Entity < handle & aod.common.mixins.Entity
% ENTITY (Abstract)
%
% Description:
%   Abstract superclass providing a consistent interface to all entities in
%   AOData's object model
%
% Constructor:
%   obj = aod.core.Entity()
%   obj = aod.core.Entity(name)
%   obj = aod.core.Entity(name, 'Parent', parentEntity)
%
% Properties:
%   Parent                      aod.core.Entity
%   Name                        char
%   UUID                        string
%   attributes                  aod.common.KeyValueMap
%   files                       aod.common.KeyValueMap
%   description                 string
%   notes                       string
%
% Dependent properties:
%   label                       string      (defined by specifyLabel)
%
% Public methods:
%   h = getParent(obj, className)
%   setName(obj, name)
%   setDescription(obj, txt, overwrite)
%
%   setNote(obj, txt)
%   removeNote(obj, ID)
%
%   tf = hasAttr(obj, attrName)
%   setAttr(obj, varargin)
%   value = getAttr(obj, attrName, msgLevel)
%   removeAttr(obj, attrName)
%
%   tf = hasFile(obj, fileName)
%   setFile(obj, fileName, filePath)
%   value = getFile(obj, fileName, errorType)
%   value = getExptFile(obj, fileName, varargin)
%   removeFile(obj, fileName)
%
%   tf = isequal(obj, other)
%
% Protected methods:
%   value = specifyLabel(obj)
%   parseAttributes(obj, varargin)
%   sync(obj)
%   validateName(obj)
%
% Static methods:
%   value = specifyAttributes()
%
% Protected methods (with aod.persistent.Entity subclass access allowed):
%   addParent(obj, parent)
%
% Private methods:
%   tf = validateParent(obj, parent)

% By Sara Patterson, 2023 (AOData)
% --------------------------------------------------------------------------

    properties (SetAccess = private)
        % The Entity's parent Entity
        Parent                      {mustBeScalarOrEmpty} % aod.core.Entity subclass
        % User-defined name for the entity, defines the HDF5 group name
        Name                        string {mustBeScalarOrEmpty} = string.empty()
        % Unique identifier for the entity
        UUID                        string = string.empty()
        % A description of the entity
        description                 string = string.empty()
        % Notes about the entity
        notes           (:,1)       string = string.empty()
        % The date the entity was created
        dateCreated                 datetime = datetime.empty()
        % The date and time the entity was last modified
        lastModified                datetime = datetime.empty()
    end

    properties
        Schema
    end

    properties (Hidden, SetAccess = private)
        % The entity's type, aod.common.EntityTypes
        entityType                  % aod.common.EntityTypes
    end

    properties (SetObservable, SetAccess = protected)
        % Files associated with the entity
        files                       % aod.common.KeyValueMap
        % Metadata for the entity which maps to HDF5 attributes
        attributes                  % aod.common.KeyValueMap
    end

    properties (Dependent)
        % Automated name from specifyLabel(), used for HDF5 group name if the name property is not set
        label                       char
    end

    properties (Hidden, Dependent)
        % The name that will be used for the HDF5 group
        groupName                   char
    end

    properties (Hidden, Access = private)
        DatasetManager
    end

    methods
        function obj = Entity(varargin)
            % Input parsing and processing
            ip = aod.util.InputParser();
            addOptional(ip, 'Name', [], @(x) istext(x) | isempty(x));
            addParameter(ip, 'Parent', []);
            parse(ip, varargin{:});

            if ~isempty(ip.Results.Name)
                obj.setName(ip.Results.Name);
            end

            % Assign entity type
            obj.entityType = aod.common.EntityTypes.get(obj);

            % Generate a random unique identifier to distinguish the class
            obj.UUID = aod.util.generateUUID();
            % Get current time for dateCreated and lastModified
            obj.dateCreated = datetime("now");
            obj.lastModified = obj.dateCreated;

            % Set the Parent, if necessary
            if ~isempty(ip.Results.Parent)
                obj.setParent(ip.Results.Parent);
            end

            % Initialize containers
            obj.Schema = aod.core.Schema(obj);
            obj.files = aod.common.KeyValueMap();
            obj.attributes = aod.common.KeyValueMap();

            % Parse unmatched inputs
            obj.parseAttributes(ip.Unmatched);

            % Set listeners for any SetObservable properties
            obj.assignListeners();
        end
    end

    % Dependent set/get methods
    methods
        function value = get.label(obj)
            value = obj.specifyLabel();
        end

        function value = get.groupName(obj)
            value = obj.specifyGroupName();
        end
    end

    methods (Sealed)
        function setName(obj, name)
            % Set entity's name
            %
            % Syntax:
            %   setName(obj, name)
            %
            % Inputs:
            %   name            string
            %       Name of entity
            % -------------------------------------------------------------
            if ~isscalar(obj)
                arrayfun(@(x) setName(x, name), obj);
                return
            end

            if nargin < 2
                name = [];
            end
            obj.Name = name;
        end

        function setDescription(obj, txt)
            % Set entity's description
            %
            % Syntax:
            %   setDescription(obj, txt)
            %
            % Inputs:
            %   txt         string
            %       Description
            % Optional inputs:
            %   overwrite   logical (default = false)
            %       Whether to overwrite existing description
            %
            % Notes:
            %   Running setDescription(obj) without providing the 2nd input
            %   will just delete the current description, if present.
            % -------------------------------------------------------------
            arguments
                obj
                txt         string = string.empty()
            end

            obj.description = txt;
        end

        function setNote(obj, txt, ID)
            % Append a note to the entity
            %
            % Syntax:
            %   obj.setNote(txt)
            %   obj.setNote(txt, ID)
            %
            % Examples:
            %   % Append a new note
            %   obj.setNote("This is a note");
            %
            %   % Overwrite the 2nd note
            %   obj.setNote("New note content", 2);
            % -------------------------------------------------------------
            arguments
                obj
                txt             string
                ID              {mustBeInteger} = 0
            end

            if ~isscalar(obj)
                arrayfun(@(x) setNote(x, txt, ID), obj);
                return
            end

            if ID > 0
                obj.notes(ID) = txt;
                return
            end

            if isempty(obj.notes)
                obj.notes = txt;
            else
                obj.notes = cat(1, obj.notes, txt);
            end
        end

        function removeNote(obj, ID)
            % Remove note(s) from the entity
            %
            % Description:
            %   Remove a specific note by ID or clear all notes
            %
            % Syntax:
            %   obj.removeNote(obj, ID)
            %
            % Examples:
            %   % Remove 2nd note
            %   obj.removeNote(2)
            %
            %   % Clear all notes
            %   obj.removeNote("all")
            % -------------------------------------------------------------

            if ~isscalar(obj)
                arrayfun(@(x) removeNote(x, ID), obj);
                return
            end

            if istext(ID) && strcmpi(ID, 'all')
                obj.notes = string.empty();
            elseif isnumeric(ID)
                mustBeInteger(ID); mustBeInRange(ID, 1, numel(obj.notes));
                obj.notes(ID) = [];
            end
        end

        function tf = isExpected(obj, propName, specType)
            % Determine if attribute/dataset is in entity's specification
            %
            % Syntax:
            %   tf = isExpected(obj, propName)
            %   tf = isExpected(obj, propName, specType)
            %
            % Inputs:
            %   propName        char
            %   specType        char    (default = "all")
            %       Either "dataset", "attribute", "file" or "all"
            %
            % Outputs:
            %   tf              logical
            %       Whether the dataset/attribute is expected
            % --------------------------------------------------------------

            if nargin < 3 || strcmpi(specType, "all")
                % FIXME Add method to schema
                tf = obj.Schema.has(propName);
            else
                tf = obj.Schema.has(propName, specType);
            end
        end
    end

    % Dataset methods
    methods (Sealed)
        function setProp(obj, propName, propValue, errorType)

            arguments
                obj
                propName        char
                propValue
                errorType               = aod.infra.ErrorTypes.ERROR
            end

            errorType = aod.infra.ErrorTypes.init(errorType);

            if ~isscalar(obj)
                arrayfun(@(x) setProp(x, propName, propValue, errorType), propValue);
                return
            end

            % Check whether the property is in specs
            propSpec = obj.Schema.Datasets.get(propName, errorType);
            if isempty(propSpec)
                error('setProp:PropertyNotFound',...
                    'The property "%s" was not found', propName);
            end

            [isValid, ME] = propSpec.validate(propValue);
            if ~isValid
                %id = 'setProp:InvalidValue';
                %msg = "Value did not pass specification validation";
                if errorType == aod.infra.ErrorTypes.ERROR
                    throw(ME); % TODO: Change identifier
                elseif errorType == aod.infra.ErrorTypes.WARNING
                    throwWarning(ME);
                end
            end

            obj.(propName) = propValue;
        end
    end

    % Attribute methods
    methods (Sealed)
        function setAttr(obj, varargin)
            % Add attribute(s) to the attribute property
            %
            % Syntax:
            %   obj.setAttr(attrName, value)
            %   obj.setAttr(attrName1, value1, attrName2, value2)
            %   obj.setAttr(struct)
            %
            % Examples:
            %   obj = aod.builtin.devices.BandpassFilter(607, 70);
            %   % Single attribute
            %   obj.setAttr('Bandwidth', 20)
            %   % Multiple attributes
            %   obj.setAttr('Bandwidth', 20, 'Wavelength', 510)
            %   % From structure
            %   S = struct('Bandwidth', 20, 'Wavelength', 510)
            %   obj.setAttr(S);
            % -------------------------------------------------------------

            if ~isscalar(obj)
                arrayfun(@(x) setAttr(x, varargin{:}), obj);
                return
            end

            % Run through attribute schema parser
            ip = obj.Schema.Attributes.getParser();
            ip.parse(varargin{:});

            % Set specified attributes, if needed
            k1 = setdiff(ip.Parameters, ip.UsingDefaults);
            if ~isempty(k1)
                for i = 1:numel(k1)
                    obj.attributes(k1{i}) = ip.Results.(k1{i});
                end
            end
            % Set adhoc attributes, if needed
            k2 = fieldnames(ip.Unmatched);
            if ~isempty(k2)
                for i = 1:numel(ip.Unmatched)
                    obj.attributes(k2{i}) = ip.Unmatched.(k2{i});
                end
            end
        end

        function removeAttr(obj, attrName)
            % Remove a attribute by name from attributes property
            %
            % Syntax:
            %   removeAttr(obj, attrName)
            %
            % Examples:
            %   obj.removeAttr('Bandwidth')
            % -------------------------------------------------------------
            arguments
                obj
                attrName       char
            end

            if ~isscalar(obj)
                arrayfun(@(x) removeAttr(x, attrName), obj);
            end

            if obj.hasAttr(attrName)
                % Set to empty if in schema, remove if ad-hoc
                if obj.Schema.Attributes.has(attrName)
                    obj.attributes(attrName) = [];
                else
                    remove(obj.attributes, attrName);
                end
            end
        end
    end

    % File methods
    methods (Sealed)
        function setFile(obj, fileName, filePath)
            % Add or modify a file
            %
            % Description:
            %   Adds to files prop, stripping out homeDirectory and
            %   trailing/leading whitespace, if needed
            %
            % Syntax:
            %   addFile(obj, fileName, filePath)
            % -------------------------------------------------------------

            arguments
                obj
                fileName                char
                filePath                char
            end

            if ~isscalar(obj)
                arrayfun(@(x) setFile(x, fileName, filePath), obj);
                return
            end

            if strcmpi(fileName, 'all')
                error('setFile:InvalidName',...
                    'The name "all" is reserved for operations on all files');
            end

            % TODO: validate with schema

            fPath = obj.getHomeDirectory();
            if ~isempty(fPath)
                filePath = erase(filePath, fPath);
            end
            filePath = strtrim(filePath);
            obj.files(fileName) = filePath;
        end

        function removeFile(obj, fileName)
            % Remove a file by name from files property
            %
            % Syntax:
            %   removeFile(obj, fileName)
            %
            % Examples:
            %   obj.removeFile('MyFile')
            %
            %   % Remove all files
            %   obj.removeFile('all');
            % -------------------------------------------------------------
            arguments
                obj
                fileName            char
            end

            if ~isscalar(obj)
                arrayfun(@(x) removeFile(x, fileName), obj);
                return
            end

            if strcmpi(fileName, 'all')
                obj.files = aod.common.KeyValueMap();
            elseif obj.hasFile(fileName)
                remove(obj.files, fileName);
            end
        end

        function fileValue = getFile(obj, fileName, errorType)
            % Get a file by name (use for absolute file paths)
            %
            % Syntax:
            %   fileValue = getFile(obj, fileName, messageType)
            %
            % Inputs:
            %   fileName       char
            % Optional inputs:
            %   errorType      aod.infra.ErrorTypes (default = NONE)
            % -------------------------------------------------------------

            arguments
                obj
                fileName        char
                errorType       = aod.infra.ErrorTypes.NONE
            end

            import aod.infra.ErrorTypes
            errorType = ErrorTypes.init(errorType);

            if ~isscalar(obj)
                fileValue = aod.util.arrayfun(...
                    @(x) string(getFile(x, fileName, ErrorTypes.MISSING)), obj);
                fileValue = standardizeMissing(fileValue, "");
                return
            end

            if obj.hasFile(fileName)
                fileValue = obj.files(fileName);
            else
                switch errorType
                    case ErrorTypes.ERROR
                        error('getFile:NotFound',...
                            'Did not find %s in files', fileName);
                    case ErrorTypes.WARNING
                        warning('getFile:NotFound',...
                            'Did not find %s in files', fileName);
                        fileValue = char.empty();
                    case ErrorTypes.MISSING
                        fileValue = missing;
                    case ErrorTypes.NONE
                        fileValue = char.empty();
                end
            end
        end

        function fileValue = getExptFile(obj, fileName, varargin)
            % Get file & append homeDirectory (use for relative file paths)
            %
            % Description:
            %   Same as getFile but appends experiment path to the output.
            %   Use when working with file paths relative to the experiment
            %   folder.
            %
            % Syntax:
            %   fileValue = getExptFile(obj, fileName, varargin)
            %
            % Notes:
            %   Optional inputs are passed to getFile()
            % -------------------------------------------------------------

            if ~isscalar(obj)
                fileValue = arrayfun(@(x) getExptFile(x, fileName, varargin{:}), obj);
                return
            end

            fPath = obj.getHomeDirectory();
            if isempty(fPath)
                error("getExptFile:NoHomeDirectory",...
                    "Add entity to experiment to use getExptFile");
            end

            fileValue = obj.getFile(fileName, varargin{:});
            if ~isempty(fileValue) || ~ismissing(fileValue)
                fileValue = fullfile(fPath, fileValue);
            end
        end

        function out = getHomeDirectory(obj)
            % Return the home directory from Experiment
            %
            % Description:
            %   Recursively searches Parent for Experiment and returns the
            %   homeDirectory property
            %
            % Syntax:
            %   out = getHomeDirectory(obj)
            %
            % Notes:
            %   If multiple entities are provided, they are assumed to be
            %   from the same Experiment
            % -------------------------------------------------------------
            h = getParent(obj(1), 'Experiment');
            if ~isempty(h)
                out = h.homeDirectory;
            else
                out = [];
            end
        end
    end

    % Methods meant to be overwritten by subclasses, if needed
    methods (Access = protected)
        function value = specifyLabel(obj)
            % Get entity's label
            %
            % Description:
            %   Determines dependent property label. Returns "name" if set
            %   or class name without packages if "name" is empty.
            %   Subclasses can overload this method to define automated
            %   naming for entities rather than requiring user to input a
            %   name upon instantiation. Examples are below in "See also".
            %
            % Syntax:
            %   value = obj.specifyLabel();
            %
            % See also:
            %   aod.builtin.devices.Pinhole,
            %   aod.builtin.devices.DichroicFilter
            % -------------------------------------------------------------
            if isempty(obj.Name)
                value = char(getClassWithoutPackages(obj));
            else
                value = obj.Name;
            end
        end

        function value = specifyGroupName(obj)
            % Determines the HDF5 group name for the entity.
            %
            % Description:
            %   Subclasses can overwrite the default rules if needed, which
            %   are that the "name" property is used unless empty. If the
            %   name property is empty, the "label" property is used.
            %
            % Syntax:
            %   value = specifyGroupName
            %
            % See also:
            %   aod.core.Epoch.specifyGroupName
            % -------------------------------------------------------------

            if aod.util.isempty(obj.Name)
                value = obj.label;
            else
                value = obj.Name;
            end
        end
    end

    methods (Access = protected)
        function sync(obj)
            % Sync entity with experiment hierarchy, check for conflicts
            %
            % Description:
            %   Sync is called when an object's Parent is set. Use for
            %   aspects of entity building that require access to the
            %   experiment hierarchy.
            %   By default, sync ensures the homeDirectory is purged from
            %   file names containing the homeDirectory to facilitate
            %   relative file paths later on. Any properties containing an
            %   aod.core.Entity subclass that are not Parent or a container
            %   are checked against the full experiment hierarchy to
            %   ensure a matching UUID is present (will be needed when
            %   writing to HDF5 as a link)
            % -------------------------------------------------------------
            h = obj.getParent('Experiment');
            if isempty(h)
                return
            end

            % Remove homeDirectory from entity files, if exists
            if ~isempty(obj.files)
                k = obj.files.keys;
                for i = 1:numel(k)
                    obj.files(k{i}) = erase(obj.files(k{i}), h.homeDirectory);
                end
            end

            % Identify properties that will be written as links and check
            % whether the linked entity exists in the experiment
            mc = metaclass(obj);
            propList = string({mc.PropertyList.Name});
            % Remove private properties
            idx = arrayfun(@(x) strcmp(x.GetAccess, 'public'), mc.PropertyList);
            propList = propList(idx);
            % Remove system properties
            propList = setdiff(propList, aod.infra.getSystemProperties());
            % Remove containers
            if ~isempty(obj.entityType.childContainers())
                propList = setdiff(propList, obj.entityType.childContainers());
            end

            for i = 1:numel(propList)
                if aod.util.isempty(obj.(propList(i)))
                    continue
                end
                if isSubclass(obj.(propList(i)), 'aod.core.Entity')
                    propValue = obj.(propList(i));
                    propType = aod.common.EntityTypes.get(propValue);
                    matches = aod.util.findByUUID(propType.collectAll(h), propValue.UUID);
                    if isempty(matches)
                        warning("Entity:SyncWarning",...
                            "prop %s (%s) does not match existing entities in experiment",...
                            propList(i), propType);
                    end
                end
            end
        end

        function isValid = validateUUIDs(obj)
            % Ensure UUID is unique among full experiment

            if isSubclass(obj.Parent, 'aod.persistent.Entity')
                allUUIDs = obj.Parent.factory.entityManager.Table.UUID;
                isValid = ~ismember(obj.UUID, allUUIDs);
            end
        end

        function isUnique = validateGroupNames(obj)
            % Check whether an entity group name is unique
            %
            % Description:
            %   Checks whether entity shares a label with existing entities
            %   in the experiment (meaning that the newest entity will
            %   overwrite the previous entity when writing to HDF5.
            %   Subclasses can add to this method to establish rules for
            %   duplicates, such as overwriting the existing entity.
            %
            % Syntax:
            %   isUnique = validateGroupNames(obj)
            % -------------------------------------------------------------
            containerName = obj.entityType.parentContainer();
            isUnique = true;

            if isempty(obj.Parent.(containerName))
                return
            end

            existingEntities = obj.Parent.(containerName);
            groupNames = getGroupName(existingEntities);
            if ismember(obj.label, groupNames)
                isUnique = false;
                warning("Entity:DuplicateGroupName",...
                    "Entity shares a group name with an existing entity: %s", obj.label);
            end
        end
    end

    methods (Access={?aod.util.Factory})
        function assignUUID(obj, uuid)
            % Assign a UUID to the entity
            %
            % Description:
            %   The same system may be used over multiple experiments and
            %   should share UUIDs. This function provides public access
            %   to aod.core.Entity's setUUID function to facilitate hard-
            %   coded UUIDs for common sources
            %
            % Syntax:
            %   obj.assignUUID(UUID)
            %
            % Notes:
            %   Access restricted to factory subclasses to protect UUIDs
            %
            % See also:
            %   aod.util.generateUUID
            % -------------------------------------------------------------
            uuid = aod.util.validateUUID(uuid);
            obj.UUID = uuid;
        end
    end

    methods (Sealed, Access = {?aod.core.Entity, ?aod.persistent.Entity, ?aod.common.mixins.ParentEntity})
        function dissociateEntity(obj)
            if ~isscalar(obj)
                arrayfun(@dissociateEntity, obj);
                return
            end
            parentContainerName = obj.entityType.parentContainer(obj);
            idx = obj.Parent.(parentContainerName) == obj;
            obj.Parent.(parentContainerName)(idx) = [];
            removeParent(obj);
        end

        function setParent(obj, parent)
            % Set the parent property of an entity
            %
            % Syntax:
            %   obj.setParent(parent)
            % -------------------------------------------------------------
            if ~isscalar(obj)
                arrayfun(@(x) setParent(x, parent), obj);
                return
            end

            if isempty(parent)
                return
            end

            if obj.validateParent(parent)
                obj.Parent = parent;
            else
                error("setParent:InvalidParentType",...
                    '%s is not a valid parent', class(parent));
            end

            % Ensure linked entities are present and clean up files
            obj.sync();
            % Ensure UUID and group name is unique among container
            obj.validateUUIDs();
            obj.validateGroupNames();
        end

        function removeParent(obj)
            % Remove the parent property of an entity
            %
            % Syntax:
            %   removeParent(obj)
            %
            % Notes:
            %   Only do this when removing an entity from the experiment
            % -------------------------------------------------------------
            if ~isscalar(obj)
                arrayfun(@(x) removeParent(x), obj);
                return;
            end

            obj.Parent = [];
        end
    end

    methods (Access = private)
        function tf = validateParent(obj, parent)
            % Determine if parent is in or subclass of allowable parents
            %
            % Syntax:
            %   tf = validateParent(parent)
            % -------------------------------------------------------------
            tf = ismember(parent.entityType, obj.entityType.validParentTypes());
        end

        function assignListeners(obj)
            % Create PostSet listeners for SetObservable properties
            %
            % Description:
            %   Any property marked SetObservable will be assigned a
            %   'PostSet' listener with a callback to update the
            %   lastChanged property. Useful when a property change might
            %   impact the properties of other objects
            %
            % Syntax:
            %   assignListeners(obj)
            % -------------------------------------------------------------
            mc = metaclass(obj);
            idx = find(arrayfun(@(x) x.SetObservable, mc.PropertyList));

            if isempty(idx)
                return
            end

            for i = 1:numel(idx)
                addlistener(obj, mc.PropertyList(idx(i)).Name,...
                    'PostSet', @obj.onPropertyChange);
            end
        end

        function onPropertyChange(obj, ~, ~)
            % Callback to update lastModified when property changes
            %
            % Description:
            %   Triggered by the setting of a "SetObservable" property and
            %   updated the lastModified property to current date/time
            % -------------------------------------------------------------
            obj.lastModified = datetime("now");
        end
    end

% MATLAB builtin functions
    methods
        function delete(obj)
            if ~isempty(obj.Parent) && isvalid(obj.Parent)
                idx = obj.Parent.(obj.entityType.parentContainer()) == obj;
                obj.Parent.(obj.entityType.parentContainer())(idx) = [];
            end
        end
    end

% Static specification methods
    methods (Static)
        function value = specifyAttributes()
            % Initializes AttributeManager, subclasses can extend
            %
            % Syntax:
            %   value = specifyAttributes()
            % -------------------------------------------------------------
            value = aod.schema.collections.AttributeCollection([]);
        end

        function value = specifyDatasets(value)
            % Subclasses can extend to modify DatasetManager
            %
            % Syntax:
            %   mngr = specifyDatasets(mngr)
            %
            % Inputs:
            %   mngr        aod.specification.DatasetManager
            % -------------------------------------------------------------
        end

        function value = specifyFiles()
            % Subclasses can extend to modify the FileCollection schema
            %
            % Syntax:
            %   value = specifyFiles()
            %
            % Output:
            %   value       aod.schema.FileCollection
            % -------------------------------------------------------------
            value = aod.schema.collections.FileCollection([]);
        end
    end
end