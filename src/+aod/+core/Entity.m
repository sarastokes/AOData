classdef (Abstract) Entity < handle 
% ENTITY (Abstract)
%
% Description:
%   Base class for information related to an experiment
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
%   parameters                  aod.util.Parameters
%   files                       aod.util.Parameters
%   description                 string
%   notes                       string
%
% Dependent properties:
%   label                       string      (defined by getLabel)
%
% Public methods:
%   h = ancestor(obj, className)
%   setName(obj, name)
%   setDescription(obj, txt, overwrite)
%
%   addNote(obj, txt)
%   removeNote(obj, ID)
%
%   tf = hasParam(obj, paramName)
%   setParam(obj, varargin)
%   value = getParam(obj, paramName, msgLevel)
%   removeParam(obj, paramName)
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
%   sync(obj)
%   checkGroupNames(obj)
%
% Protected methods (with aod.persistent.Entity subclass access allowed):
%   addParent(obj, parent)
%
% Private methods:
%   tf = isValidParent(obj, parent)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        % The Entity's parent Entity (aod.core.Entity subclass)
        Parent                      % aod.core.Entity
        % User-defined name for the entity, defines the HDF5 group name
        Name(1,:)                   char = char.empty()
        % Unique identifier for the entity
        UUID                        string = string.empty()
        % A description of the entity
        description                 string = string.empty() 
        % Notes about the entity
        notes                       string = string.empty()
    end

    properties (Hidden, SetAccess = private)
        % The entity's type (aod.core.EntityTypes)
        entityType                  %aod.core.EntityTypes
    end

    properties (SetAccess = protected)
        % Files associated with the entity
        files                       % aod.util.Parameters
        % Metadata for the entity which maps to HDF5 attributes
        parameters                  % aod.util.Parameters
    end
    
    properties (Dependent)
        % Automated name from getLabel(), used for HDF5 group name if the name property is not set
        label
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
            obj.entityType = aod.core.EntityTypes.get(obj);

            % Generate a random unique identifier to distinguish the class
            obj.UUID = aod.util.generateUUID();

            % Set the Parent, if necessary
            if ~isempty(ip.Results.Parent)
                obj.setParent(ip.Results.Parent);
            end
            
            % Initialize containers
            obj.files = aod.util.Parameters();
            obj.parameters = aod.util.Parameters();
            
        end

        function value = get.label(obj)
            value = obj.getLabel();
        end
    end

    methods
        function h = ancestor(obj, className)
            % Get parent entity matching a specific entityType
            %
            % Description:
            %   Recursively search 'Parent' property for an entity matching
            %   or subclassing className
            %
            % Syntax:
            %   h = obj.ancestor(className)
            % -------------------------------------------------------------
            h = obj;
            if isa(className, 'aod.core.EntityTypes')
                while h.entityType ~= className
                    h = h.Parent;
                    if isempty(h)
                        break
                    end
                end
            else
                while ~isSubclass(h, className)
                    h = h.Parent;
                    if isempty(h)
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
            % -------------------------------------------------------------
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
        
        function addNote(obj, txt)
            % Append a note to the entity
            % 
            % Syntax:
            %   obj.addNote(txt)
            % -------------------------------------------------------------
            arguments
                obj
                txt             string
            end

            if ~isscalar(obj)
                arrayfun(@(x) addNote(x, txt), obj);
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

    % Parameter methods
    methods (Sealed)
        function tf = hasParam(obj, paramName)
            % Check whether entity has a parameter
            %
            % Description:
            %   Check whether entity parameters has a specific parameter
            %
            % Syntax:
            %   tf = hasParam(obj, paramName)
            %
            % Examples:
            %   % See whether entity has parameter 'MyParam'
            %   tf = obj.hasParam('MyParam')
            % -------------------------------------------------------------
            arguments
                obj
                paramName       char
            end

            if ~isscalar(obj)
                tf = arrayfun(@(x) x.hasParam(paramName), obj);
                return
            end
            
            tf = obj.parameters.isKey(paramName);
        end

        function paramValue = getParam(obj, paramName, errorType)
            % Get the value of a parameter
            %
            % Description:
            %   Return the value of a specific parameter. 
            %
            % Syntax:
            %   paramValue = getParam(obj, paramName, messageType)
            %
            % Inputs:
            %   paramName       char
            % Optional inputs:
            %   errorType       aod.util.ErrorTypes (default = ERROR) 
            %
            % Examples:
            %   % Get the value of 'MyParam'
            %   paramValue = obj.getParam('MyParam')           
            % -------------------------------------------------------------

            arguments
                obj
                paramName           char 
                errorType           = []
            end
            
            import aod.util.ErrorTypes
            if isempty(errorType)
                errorType = ErrorTypes.ERROR;
            else
                errorType = ErrorTypes.init(errorType);
            end

            if ~isscalar(obj)
                paramValue = arrayfun(@(x) x.getParam(paramName, errorType), obj);
                return
            end

            if obj.hasParam(paramName)
                paramValue = obj.parameters(paramName);
            else
                switch errorType 
                    case ErrorTypes.ERROR 
                        error('getParam:NotFound',... 
                            'Did not find %s in parameters', paramName);
                    case ErrorTypes.WARNING 
                        warning('getParam:NotFound',... 
                            'Did not find %s in parameters', paramName);
                        paramValue = [];
                    case ErrorTypes.MISSING
                        paramValue = NaN;
                    case ErrorTypes.NONE
                        paramValue = [];
                end
            end
        end

        function setParam(obj, varargin)
            % Add or change parameter(s)
            %
            % Description:
            %   Add parameter(s) to the parameter property
            %
            % Syntax:
            %   obj.setParam(paramName, value)
            %   obj.setParam(paramName1, value1, paramName2, value2)
            %   obj.setParam(struct)
            % -------------------------------------------------------------

            if ~isscalar(obj)
                arrayfun(@(x) setParam(x, varargin{:}), obj);
                return
            end

            if nargin == 2 && isstruct(varargin{1})
                S = varargin{1};
                k = fieldnames(S);
                for i = 1:numel(k)
                    obj.parameters(k{i}) = S.(k{i});
                end
            else
                for i = 1:(nargin - 1)/2
                    obj.parameters(varargin{(2*i)-1}) = varargin{2*i};
                end
            end
        end

        function removeParam(obj, paramName)
            % Remove a parameter by name
            %
            % Description:
            %   Remove a parameter by name from parameters property
            %
            % Syntax:
            %   removeParam(obj, paramName)
            % -------------------------------------------------------------
            arguments
                obj
                paramName       char
            end

            if ~isscalar(obj)
                arrayfun(@(x) removeParam(x, paramName), obj);
            end

            if obj.hasParam(paramName)
                remove(obj.parameters, paramName);
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

            if ~isscalar(obj)
                arrayfun(@(x) removeFile(x, fileName), obj);
                return
            end

            if strcmpi(fileName, 'all')
                obj.files = aod.util.Parameters();
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
            %   errorType      aod.util.ErrorTypes (default = ERROR)            
            % -------------------------------------------------------------

            arguments
                obj
                fileName        char 
                errorType       = []
            end

            import aod.util.ErrorTypes
            if isempty(errorType)
                errorType = ErrorTypes.ERROR;
            else
                errorType = ErrorTypes.init(errorType);
            end

            if ~isscalar(obj)
                fileValue = aod.util.arrayfun(@(x) getFile(x, fileName, ErrorTypes.NONE), obj);
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
                        fileValue = [];
                    case ErrorTypes.MISSING
                        fileValue = NaN;
                    case ErrorTypes.NONE
                        fileValue = [];
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

            fileName = convertStringsToChars(fileName);

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
            if isempty(fileValue)
                fileValue = [];
            else
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
            h = ancestor(obj(1), 'aod.core.Experiment');
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
            h = obj.ancestor('aod.core.Experiment');
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
            propList = setdiff(propList, aod.h5.getSystemProperties());
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
                    propType = aod.core.EntityTypes.get(propValue);
                    matches = aod.util.findByUUID(propType.collectAll(h), propValue.UUID);
                    if isempty(matches)
                        warning("Entity:SyncWarning",...
                            "prop %s (%s) does not match existing entities in experiment",...
                            propList(i), propType);
                    end
                end
            end
        end

        function isUnique = checkGroupNames(obj)
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
            %   isUnique = checkGroupNames(obj)
            % -------------------------------------------------------------
            containerName = obj.entityType.parentContainer();
            isUnique = true;

            if isempty(obj.Parent.(containerName))
                return
            end

            existingEntities = obj.Parent.(containerName);
            groupNames = string({existingEntities.Name});
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
            
            if obj.isValidParent(parent)
                obj.Parent = parent;
            else
                error("setParent:InvalidParentType",...
                    '%s is not a valid parent', class(parent));
            end

            obj.sync();
            obj.checkGroupNames();
        end
    end

    methods (Access = private)
        function tf = isValidParent(obj, parent)
            % Determine if parent is in or subclass of allowable parents
            %
            % Syntax:
            %   tf = isValidParent(parent)
            % -------------------------------------------------------------
            try
                tf = ismember(parent.entityType, obj.entityType.validParentTypes());
            catch ME
                if strcmp(ME.identifier, 'MATLAB:index:expected_one_output_from_intermediate_indexing')
                    assignin('base', 'obj', obj);
                    assignin('base', 'parent', parent);
                else
                    rethrow(ME);
                end
            end
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
end 