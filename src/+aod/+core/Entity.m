classdef (Abstract) Entity < handle 
% ENTITY (Abstract)
%
% Description:
%   Parent class for all entities in AOData's object model (core)
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
%   attributes                  aod.common.Attributes
%   files                       aod.common.Attributes
%   description                 string
%   notes                       string
%
% Dependent properties:
%   label                       string      (defined by getLabel)
%   expectedAttributes          aod.util.AttributeManager
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
%   value = getLabel(obj)
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
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        % The Entity's parent Entity, aod.core.Entity subclass
        Parent                      % aod.core.Entity
        % User-defined name for the entity, defines the HDF5 group name
        Name(1,:)                   char = char.empty()
        % Unique identifier for the entity
        UUID                        string = string.empty()
        % A description of the entity
        description                 string = string.empty() 
        % Notes about the entity
        notes                       string = string.empty()
        % The date the entity was created
        DateCreated                 datetime = datetime.empty()
        % The date and time the entity was last modified
        LastModified                datetime = datetime.empty()
    end

    properties (Hidden, SetAccess = private)
        % The entity's type, aod.common.EntityTypes
        entityType                  %aod.common.EntityTypes
    end

    properties (SetObservable, SetAccess = protected)
        % Files associated with the entity
        files                       % aod.common.Attributes
        % Metadata for the entity which maps to HDF5 attributes
        attributes                  % aod.common.Attributes
    end
    
    properties (Dependent)
        % Automated name from getLabel(), used for HDF5 group name if the name property is not set
        label                       char
        % Expected attribute names, optional default values and validation
        expectedAttributes          % aod.util.AttributeManager
        % Expected dataset names
        expectedDatasets            % aod.util.DatasetManager
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
            % Get current time for DateCreated and LastModified
            obj.DateCreated = datetime("now");
            obj.LastModified = obj.DateCreated;

            % Set the Parent, if necessary
            if ~isempty(ip.Results.Parent)
                obj.setParent(ip.Results.Parent);
            end
            
            % Initialize containers
            obj.files = aod.common.Attributes();
            obj.attributes = aod.common.Attributes();
            
            % Parse unmatched inputs
            obj.parseAttributes(ip.Unmatched);

            % Set listeners for any SetObservable properties
            obj.assignListeners();

            % Initialize DatasetManager for basis of expectedDatasets
            obj.DatasetManager = aod.util.DatasetManager.populate(obj);
        end
    end

    % Dependent set/get methods
    methods 
        function value = get.label(obj)
            value = obj.getLabel();
        end

        function value = get.expectedAttributes(obj)
            value = obj.specifyAttributes();
        end

        function value = get.expectedDatasets(obj)
            value = obj.specifyDatasets();
        end

        function value = get.groupName(obj)
            if isempty(obj.Name)
                value = obj.label;
            else
                value = obj.Name;
            end
        end
    end

    % Hierarchy methods
    methods (Sealed)
        function out = getParent(obj, className)
            % Get the parent of an entity or ancestor of a specific type
            %
            % Description:
            %   Can be accessed through the Parent property, but this 
            %   method will concatenate parents if more than one entity 
            %   is provided
            %
            % Syntax:
            %   % Get the parent of one entity (equivalent to obj.Parent)
            %   h = obj.getParent()
            % -------------------------------------------------------------
            if nargin < 2
                className = [];
            end

            if ~isscalar(obj)
                out = aod.util.arrayfun(@(x) getParent(x, className), obj);
                return
            end
            
            if isempty(className)
                out = obj.Parent;
                return 
            end

            % See whether input is an entity type
            try
                className = aod.common.EntityTypes.get(className);
            catch ME
                if ~strcmp(ME.identifier, "get:UnknownEntity")
                    rethrow(ME);
                end
            end

            out = obj;
            if isa(className, 'aod.common.EntityTypes')
                while out.entityType ~= className
                    out = out.Parent;
                    if isempty(out)
                        break
                    end
                end
            else
                while ~isSubclass(out, className)
                    out = out.Parent;
                    if isempty(out)
                        break
                    end
                end
            end
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
    end

    % Attribute methods
    methods (Sealed)
        function tf = hasAttr(obj, attrName)
            % Check whether entity has a attribute
            %
            % Description:
            %   Check whether entity attributes has a specific attribute
            %
            % Syntax:
            %   tf = hasAttr(obj, attrName)
            %
            % Examples:
            %   % See whether entity has attribute 'MyAttr'
            %   tf = obj.hasAttr('MyAttr')
            % -------------------------------------------------------------
            arguments
                obj
                attrName       char
            end

            if ~isscalar(obj)
                tf = arrayfun(@(x) x.hasAttr(attrName), obj);
                return
            end
            
            tf = obj.attributes.isKey(attrName);
        end

        function attrValue = getAttr(obj, attrName, errorType)
            % Get the value of a attribute
            %
            % Description:
            %   Return the value of a specific attribute. 
            %
            % Syntax:
            %   attrValue = getAttr(obj, attrName, errorType)
            %
            % Inputs:
            %   attrName       char
            % Optional inputs:
            %   errorType       aod.infra.ErrorTypes (default = WARNING) 
            %
            % Examples:
            %   % Get the value of 'MyAttr'
            %   attrValue = obj.getAttr('MyAttr')           
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
                attrValue = aod.util.arrayfun(...
                    @(x) x.getAttr(attrName, ErrorTypes.MISSING), obj);

                % Parse missing values
                isMissing = getMissing(attrValue);
                if all(isMissing)
                    error('getAttr:NotFound', 'Did not find attribute %s', attrName);
                end

                % Attempt to return a matrix rather than a cell
                if iscell(attrValue) && any(isMissing)
                    attrValue = extractCellData(attrValue);
                end
                return
            end

            if obj.hasAttr(attrName)
                attrValue = obj.attributes(attrName);
            else
                switch errorType 
                    case ErrorTypes.ERROR 
                        error('getAttr:NotFound',... 
                            'Did not find %s in attributes', attrName);
                    case ErrorTypes.WARNING 
                        warning('getAttr:NotFound',... 
                            'Did not find %s in attributes', attrName);
                        attrValue = [];
                    case ErrorTypes.MISSING
                        attrValue = missing;
                    case ErrorTypes.NONE
                        attrValue = [];
                end
            end
        end

        function setAttr(obj, varargin)
            % Add or change attribute(s)
            %
            % Description:
            %   Add attribute(s) to the attribute property
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

            % Run through expectedAttributes parser
            ip = obj.expectedAttributes.getParser();
            ip.parse(varargin{:});

            % Set expected attributes, if needed
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
            % Remove a attribute by name
            %
            % Description:
            %   Remove a attribute by name from attributes property
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
                % Set to empty if expected, remove if ad-hoc
                if obj.expectedAttributes.hasAttr(attrName)
                    obj.attributes(attrName) = [];
                else
                    remove(obj.attributes, attrName);
                end
            end
        end
    end

    % File methods
    methods (Sealed)
        function tf = hasFile(obj, fileName)
            % Check whether entity has a file
            %
            % Description:
            %   Check whether entity files has a specific file name
            %
            % Syntax:
            %   tf = hasFile(obj, fileName)
            %
            % Examples:
            %   % Check for the file named 'MyFile'
            %   tf = obj.hasFile('MyFile')
            % -------------------------------------------------------------
            arguments
                obj 
                fileName                char
            end

            if ~isscalar(obj)
                tf = arrayfun(@(x) hasFile(x, fileName), obj);
                return
            end

            tf = obj.files.isKey(fileName);
        end

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

            fPath = obj.getHomeDirectory();
            if ~isempty(fPath)
                filePath = erase(filePath, fPath);
            end
            filePath = strtrim(filePath);
            obj.files(fileName) = filePath;
        end

        function removeFile(obj, fileName)
            % Remove a file by name or clear all files
            %
            % Description:
            %   Remove a file by name from files property
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
                obj.files = aod.common.Attributes();
            elseif obj.hasFile(fileName)
                remove(obj.files, fileName);
            end
        end

        function fileValue = getFile(obj, fileName, errorType)
            % Get a file by name (use for absolute file paths)
            %
            % Description:
            %   Return the value of a specific file name 
            %
            % Syntax:
            %   fileValue = getFile(obj, fileName, messageType)
            %
            % Inputs:
            %   fileName       char
            % Optional inputs:
            %   errorType      aod.infra.ErrorTypes (default = ERROR)            
            % -------------------------------------------------------------

            arguments
                obj
                fileName        char 
                errorType       = []
            end

            import aod.infra.ErrorTypes
            if isempty(errorType)
                errorType = ErrorTypes.ERROR;
            else
                errorType = ErrorTypes.init(errorType);
            end

            if ~isscalar(obj)
                fileValue = aod.util.arrayfun(...
                    @(x) string(getFile(x, fileName, ErrorTypes.NONE)), obj);
                fileValue = standardizeMissing(fileValue, "");
                return
            end

            if obj.hasFile(fileName)
                fileValue = obj.files(fileName);
            else
                switch errorType 
                    case ErrorTypes.ERROR 
                        error('getFile:NotFound', 'Did not find %s in files', fileName);
                    case ErrorTypes.WARNING 
                        warning('getFile:NotFound', 'Did not find %s in files', fileName);
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
            h = getParent(obj(1), 'aod.core.Experiment');
            if ~isempty(h)
                out = h.homeDirectory;
            else
                out = [];
            end
        end

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
            %   Not recommended!
            %
            % See also:
            %   aod.util.generateUUID
            % -------------------------------------------------------------
            uuid = aod.util.validateUUID(uuid);
            obj.UUID = uuid;
        end
    end

    % Methods meant to be overwritten by subclasses, if needed
    methods (Access = protected)
        function value = getLabel(obj)  
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
            %   value = obj.getLabel();
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

        function value = specifyDatasets(obj)
            value = obj.DatasetManager;
        end

        function value = populateDatasetManager(obj)
            % Initializes DatasetManager, subclasses can extend
            %
            % Syntax:
            %   value = specifyDatasets(obj)
            % -------------------------------------------------------------
            tic
            value = aod.util.DatasetManager.populate(obj);
            fprintf("Dataset time = %.2f\n", toc);
        end
    end

    methods (Access = protected)
        function parseAttributes(obj, varargin)
            % Parses varargin input to constructor with expectedAttributes
            % 
            % Syntax:
            %   parseAttributes(obj, varargin)
            %
            % See also:
            %   aod.core.Entity.specifyAttributes,
            %   aod.util.AttributeManager
            % -------------------------------------------------------------
            ip = obj.expectedAttributes.parse(varargin{:});
            f = fieldnames(ip.Results);
            for i = 1:numel(f)
                if ~isempty(ip.Results.(f{i}))
                    obj.setAttr(f{i}, ip.Results.(f{i}));
                end
            end
        end

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
            h = obj.getParent('aod.core.Experiment');
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
                if isSubclass(obj.(propList(i)), 'aod.core.Entity')
                    if isempty(obj.(propList(i)))
                        continue
                    end
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
            groupNames = string({existingEntities.groupName});
            if ismember(obj.label, groupNames)
                isUnique = false;
                warning("Entity:DuplicateGroupName",...
                    "Entity shares a group name with an existing entity: %s", obj.label);
            end
        end
    end

    methods (Sealed, Access = {?aod.core.Entity, ?aod.persistent.Entity})
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
                addlistener(obj, mc.PropertyList(idx(i)).Name, 'PostSet', @obj.onPropertyChange);
            end
        end

        function onPropertyChange(obj, ~, ~)
            % Callback to update LastModified when property changes
            %
            % Description:
            %   Triggered by the setting of a "SetObservable" property and 
            %   updated the LastModified property to current date/time
            % -------------------------------------------------------------
            obj.LastModified = datetime("now");
        end
    end

    % Overloaded MATLAB functions
    methods
        function tf = isequal(obj, entity)
            % Test whether two entities have the same UUID. If 2nd input 
            % is not an entity, returns false
            %
            % Syntax:
            %   tf = isequal(obj, entity)
            % -------------------------------------------------------------
            arguments
                obj
                entity
            end

            if aod.util.isEntitySubclass(entity)
                tf = isequal(obj.UUID, entity.UUID);
            else
                tf = false;
            end
        end
    end

    methods (Static)
        function value = specifyAttributes() 
            % Initializes AttributeManager, subclasses can extend
            %
            % Syntax:
            %   value = specifyAttributes()
            % -------------------------------------------------------------

            value = aod.util.AttributeManager();
        end
    end
end 