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
%   parameters                  aod.util.Parameters
%   files                       aod.util.Parameters
%   description                 string
%   notes                       char
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
%   clearNotes(obj)
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
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        % The Entity's parent Entity (aod.core.Entity subclass)
        Parent                      % aod.core.Entity
        % User-defined name for the entity, defines the HDF5 group name
        Name(1,:)                   char = char.empty()
        % Unique identifier for the entity
        UUID                        string = string.empty()
        % A description of the entity
        description                 char = char.empty() 
        % Notes about the entity
        notes                       char = char.empty()
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
            obj.assignEntityType();

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

        function h = ancestor(obj, className)
            % ANCESTOR
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
            % SETNAME
            %
            % Syntax:
            %   setName(obj, name)
            % -------------------------------------------------------------
            arguments
                obj
                name        char
            end
            obj.Name = name;
        end

        function setDescription(obj, txt, overwrite)
            % SETDESCRIPTION
            %
            % Syntax:
            %   setDescription(obj, txt, overwrite)
            %
            % Inputs:
            %   txt         string
            %       Description
            % Optional inputs:
            %   overwrite   logical (default = false)
            %       Whether to overwrite existing description 
            % -------------------------------------------------------------
            if nargin < 3
                overwrite = false;
            end
            assert(istext(txt), 'Description must be char or string')

            if ~isempty(obj.description) && ~overwrite 
                warning('Set overwrite=true to change existing description');
                return
            end
            obj.description = txt;
        end
        
        function addNote(obj, txt)
            % ADDNOTE
            % 
            % Syntax:
            %   obj.addNote(txt)
            % -------------------------------------------------------------
            arguments
                obj
                txt             string = string.empty()
            end

            if isempty(txt)
                return
            end

            if ~isscalar(obj)
                arrayfun(@(x) addNote(x, txt), obj);
                return
            end

            obj.notes = cat(1, obj.notes, txt);
        end

        function removeNote(obj, ID)
            % REMOVENOTE
            % 
            % Description:
            %   Remove a specific note
            %
            % Syntax:
            %   obj.removeNote(obj, ID)
            % -------------------------------------------------------------
            assert(ID > 1 && ID <= numel(out),...
                'Invalid ID %u, must be between 1-%u', ID, max(noteIDs));
            obj.notes(ID) = [];
        end

        function clearNotes(obj)
            % CLEARNOTES
            %
            % Syntax:
            %   obj.clearNotes()
            % -------------------------------------------------------------
            if ~isscalar(obj)
                arrayfun(@(x) clearNotes(x), obj);
                return
            end

            obj.notes = string.empty();
        end
    end

    % Creation/destruction methods
    methods
        function remove(obj)
            if isempty(obj.Parent)
                error('delete:NoParent', 'Entity cannot be deleted if parent is unset');
            end
            
            parentContainer = obj.entityType.parentContainer();
            h = obj.Parent.(parentContainer);
            idx = arrayfun(@(x) isequal(x, obj.UUID), h);
            h(idx) = [];
        end
    end

    % Parameter methods
    methods (Sealed)
        function tf = hasParam(obj, paramName)
            % HASPARAM
            %
            % Description:
            %   Check whether entity parameters has a specific parameter
            %
            % Syntax:
            %   tf = hasParam(obj, paramName)
            % -------------------------------------------------------------
            if ~isscalar(obj)
                tf = arrayfun(@(x) x.hasParam(paramName), obj);
                return
            end
            
            tf = obj.parameters.isKey(paramName);
        end

        function paramValue = getParam(obj, paramName, errorType)
            % GETPARAM
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
            % -------------------------------------------------------------
            import aod.util.ErrorTypes
            if nargin < 3
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
                        error('GetParam: Did not find %s in parameters', paramName);
                    case ErrorTypes.WARNING 
                        warning('GetParam: Did not find %s in parameters', paramName);
                        paramValue = [];
                    case ErrorTypes.NONE
                        paramValue = [];
                end
            end
        end

        function setParam(obj, varargin)
            % ADDPARAMETER
            %
            % Description:
            %   Add parameter(s) to the parameter property
            %
            % Syntax:
            %   obj.setParam(paramName, value)
            %   obj.setParam(paramName1, value1, paramName2, value2)
            %   obj.setParam(struct)
            % -------------------------------------------------------------
            if nargin == 1
                return
            end
            
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
            % REMOVEFILE
            %
            % Description:
            %   Remove a parameter by name from parameters property
            %
            % Syntax:
            %   removeParam(obj, paramName)
            % -------------------------------------------------------------
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
            % HASFILE
            %
            % Description:
            %   Check whether entity files has a specific file name
            %
            % Syntax:
            %   tf = hasFile(obj, fileName)
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
            % SETFILE
            %
            % Description:
            %   Adds to files prop, stripping out homeDirectory and
            %   trailing/leading whitespace, if needed
            %
            % Syntax:
            %   obj.addFile(fileName, filePath)
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

            fPath = obj.getHomeDirectory();
            if ~isempty(fPath)
                filePath = erase(filePath, fPath);
            end
            filePath = strtrim(filePath);
            obj.files(fileName) = filePath;
        end

        function removeFile(obj, fileName)
            % REMOVEFILE
            %
            % Description:
            %   Remove a file by name from files property
            %
            % Syntax:
            %   removeFile(obj, fileName)
            % -------------------------------------------------------------

            if ~isscalar(obj)
                arrayfun(@(x) removeFile(x, fileName), obj);
                return
            end

            if obj.hasFile(fileName)
                remove(obj.files, fileName);
            end
        end

        function fileValue = getFile(obj, fileName, errorType)
            % GETFILE
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
            import aod.util.ErrorTypes
            if nargin < 3
                errorType = ErrorTypes.ERROR;
            else
                errorType = ErrorTypes.init(errorType);
            end

            if ~isscalar(obj)
                fileValue = aod.util.arrayfun(@(x) getFile(x, fileName, ErrorTypes.NONE), obj);
                fileValue = string(fileValue);
                return
            end

            if obj.hasFile(fileName)
                fileValue = obj.files(fileName);
            else
                switch errorType 
                    case ErrorTypes.ERROR 
                        error('GetFile: Did not find %s in files', fileName);
                    case ErrorTypes.WARNING 
                        warning('GetFile: Did not find %s in files', fileName);
                        fileValue = [];
                    case ErrorTypes.NONE
                        fileValue = [];
                end
            end
        end

        function fileValue = getExptFile(obj, fileName, varargin)
            % GETEXPTFILE
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
            if isempty(fileValue)
                fileValue = [];
            else
                fileValue = fullfile(fPath, fileValue);
            end
        end

        function out = getHomeDirectory(obj)
            % GETHOMEDIRECTORY
            %
            % Description:
            %   Recursively searches Parent for Experiment and returns the
            %   homeDirectory property
            %
            % Syntax:
            %   out = getHomeDirectory(obj)
            % -------------------------------------------------------------
            h = ancestor(obj(1), 'aod.core.Experiment');
            if ~isempty(h)
                out = h.homeDirectory;
            else
                out = [];
            end
        end

        function assignUUID(obj, uuid)
            % ASSIGNUUID
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
            % GETLABEL
            %      
            % Syntax:
            %   value = obj.getLabel()
            % -------------------------------------------------------------
            if ~isscalar(obj)
                value = arrayfun(@(x) getLabel(x), obj);
                return
            end

            if isempty(obj.Name)
                value = char(getClassWithoutPackages(obj));
            else
                value = obj.Name;
            end
        end

        function sync(obj)
            % SYNC
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
            propList = setdiff(propList, aod.h5.getSpecialProps());
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
            % CHECKGROUPNAMES
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
            % SETPARENT
            %   
            % Syntax:
            %   obj.setParent(parent)
            % -------------------------------------------------------------
            if isempty(parent)
                return
            end
            
            if ~isscalar(obj)
                arrayfun(@(x) setParent(x, parent), obj);
                return
            end
            
            if obj.isValidParent(parent)
                obj.Parent = parent;
            else
                error('%s is not a valid parent', class(parent));
            end

            obj.sync();
            obj.checkGroupNames();
        end

        function assignEntityType(obj)
            obj.entityType = aod.core.EntityTypes.get(obj);
        end
    end

    methods (Access = private)
        function tf = isValidParent(obj, parent)
            % ISVALIDPARENT
            %
            % Description:
            %   Determine if parent is in or subclass of allowable parents
            %
            % Syntax:
            %   tf = isValidParent(parent)
            % -------------------------------------------------------------
            validParents = obj.entityType.validParentTypes;

            if isempty(validParents)
                tf = true;
                return;
            elseif strcmp(validParents, {'none'})
                tf = false;
                return
            end

            for i = 1:numel(validParents)
                if isSubclass(parent, validParents{i})
                    tf = true;
                    break
                else
                    tf = false;
                end
            end
        end
    end

    % Overloaded MATLAB functions
    methods
        function tf = isequal(obj, entity)
            % Test whether two entities have the same UUID
            %
            % Syntax:
            %   tf = isequal(obj, entity)
            % -------------------------------------------------------------
            arguments
                obj
                entity      {aod.util.mustBeEntity(entity)}
            end

            tf = isequal(obj.UUID, entity.UUID);
        end
    end
end 