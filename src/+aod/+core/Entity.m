classdef (Abstract) Entity < handle 
% ENTITY (Abstract)
%
% Description:
%   Base class for information related to an experiment
%
% Constructor:
%   obj = aod.core.Entity()
%
% Properties:
%   Parent                      aod.core.Entity
%   Name                        char
%   parameters                  aod.util.Parameters
%   files                       aod.util.Parameters
%   description                 string
%   notes                       cell
%
% Abstract protected properties:
%   allowableParentTypes        cellstr
%
% Dependent properties:
%   label                       string      (defined by getLabel)
%
% Public methods:
%   h = ancestor(obj, className)
%   setName(obj, name)
%   setDescription(obj, txt, overwrite)
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
%   value = getFile(obj, fileName, msgType)
%   value = getExptFile(obj, fileName, varargin)
%   removeFile(obj, fileName)
%
% Protected methods:
%   value = getLabel(obj)
%   sync(obj)
%   checkGroupNames(obj)
%
% Sealed Protected methods:
%   setUUID(obj, uuid)
%
% Protected methods accessible by any subclass of aod.core.Entity
%   addParent(obj, parent)
%
% Private methods:
%   tf = isValidParent(obj, parent)
%
% Static methods:
%   tf = isEntity(entity)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Parent                      % aod.core.Entity
        Name(1,:)                   char = char.empty()
        UUID                        string = string.empty()
        description                 string = string.empty() 
        notes                       string = string.empty()
    end

    properties (SetAccess = protected)
        files                       % aod.util.Parameters
        parameters                  % aod.util.Parameters
    end
    
    properties (Abstract, Hidden, Access = protected)
        allowableParentTypes        cell
    end

    properties (Dependent)
        label
    end

    methods
        function obj = Entity(name)
            if nargin > 0
                obj.setName(name);
            end

            obj.files = aod.util.Parameters();
            obj.parameters = aod.util.Parameters();
            
            obj.UUID = aod.util.generateUUID();
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
            while ~isSubclass(h, className)
                h = h.Parent;
                if isempty(h)
                    break
                end
            end
        end
    end

    methods 
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
            if isempty(txt)
                return
            end
            
            obj.notes = [obj.notes, '[[x]]', txt];
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
            out = strfind(obj.notes, '[[');
            assert(ID > 1 && ID <= numel(out),...
                'Invalid ID %u, must be between 1-%u', ID, max(noteIDs));
            if ID == numel(out)
                obj.notes = obj.notes(out(end):end);
            else
                obj.notes = [obj.notes(1:out(ID)-1), obj.notes(out(ID+1):end)];
            end
        end

        function clearNotes(obj)
            % CLEARNOTES
            %
            % Syntax:
            %   obj.clearNotes()
            % -------------------------------------------------------------
            obj.notes = string.empty();
        end
    end

    % Parameter methods
    methods
        function tf = hasParam(obj, paramName)
            % HASPARAM
            %
            % Description:
            %   Check whether entity parameters has a specific parameter
            %
            % Syntax:
            %   tf = hasParam(obj, paramName)
            % -------------------------------------------------------------
            tf = obj.parameters.isKey(paramName);
        end

        function paramValue = getParam(obj, paramName, msgType)
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
            %   msgType         aod.util.MessageTypes (default = ERROR)            
            % -------------------------------------------------------------
            import aod.util.MessageTypes
            if nargin < 3
                msgType = MessageTypes.ERROR;
            else
                msgType = MessageTypes.init(msgType);
            end

            if obj.hasParam(paramName)
                paramValue = obj.parameters(paramName);
            else
                switch msgType 
                    case MessageTypes.ERROR 
                        error('GetParam: Did not find %s in parameters', paramName);
                    case MessageTypes.WARNING 
                        warning('GetParam: Did not find %s in parameters', paramName);
                        paramValue = [];
                    case MessageTypes.NONE
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
            if obj.hasParam(paramName)
                remove(obj.parameters, paramName);
            end
        end
    end

    % File methods
    methods 
        function tf = hasFile(obj, fileName)
            % HASFILE
            %
            % Description:
            %   Check whether entity files has a specific file name
            %
            % Syntax:
            %   tf = hasFile(obj, fileName)
            % -------------------------------------------------------------
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
            if obj.hasFile(fileName)
                remove(obj.files, fileName);
            end
        end

        function fileValue = getFile(obj, fileName, msgType)
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
            %   msgType         aod.util.MessageTypes (default = ERROR)            
            % -------------------------------------------------------------
            import aod.util.MessageTypes
            if nargin < 3
                msgType = MessageTypes.ERROR;
            else
                msgType = MessageTypes.init(msgType);
            end

            if obj.hasFile(fileName)
                fileValue = obj.files(fileName);
            else
                switch msgType 
                    case MessageTypes.ERROR 
                        error('GetFile: Did not find %s in files', fileName);
                    case MessageTypes.WARNING 
                        warning('GetFile: Did not find %s in files', fileName);
                        fileValue = [];
                    case MessageTypes.NONE
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
            h = ancestor(obj, 'aod.core.Experiment');
            if ~isempty(h)
                out = h.homeDirectory;
            else
                out = [];
            end
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
            %   relative file paths later on
            % -------------------------------------------------------------
            if ~isempty(obj.files)
                h = obj.ancestor('aod.core.Experiment');
                k = obj.files.keys;
                for i = 1:numel(k)
                    obj.files(k{i}) = erase(obj.files(k{i}), h.homeDirectory);
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
            entityType = aod.core.EntityTypes.get(obj);
            containerName = entityType.containerName();
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

    methods (Sealed, Access = {?aod.core.Entity})
        function setParent(obj, parent)
            % SETPARENT
            %   
            % Syntax:
            %   obj.setParent(parent)
            % -------------------------------------------------------------
            if isempty(parent)
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

        function setUUID(obj, UUID)
            % SETUUID
            %   
            % Description:
            %   Allows subclasses to set UUID to a standardized value. 
            %   Useful in ensuring sources match across experiments
            %
            % Syntax:
            %   obj.setUUID(UUID)
            %
            % See also:
            %   generateUUID
            % -------------------------------------------------------------
            assert(isstring(UUID) & strlength(UUID) == 36,...
                'ENTITY: UUID is not properly formatted, use aod.util.generateUUID()');
            obj.UUID = UUID;
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
            tf = false;
            if isempty(obj.allowableParentTypes)
                tf = true;
                return;
            elseif strcmp(obj.allowableParentTypes, {'none'})
                tf = false;
                return
            end

            for i = 1:numel(obj.allowableParentTypes)
                if ~tf
                    if isa(parent, obj.allowableParentTypes{i}) ...
                            || ismember(obj.allowableParentTypes{i}, superclasses(class(parent)))
                        tf = true;
                    else
                        tf = false;
                    end
                end
            end
        end
    end

    methods (Static)
        function tf = isEntity(x)
            % ISENTITY
            %
            % Description:
            %   Determines whether input is a subclass of Entity
            %
            % Syntax:
            %   tf = aod.core.Entity.isEntity(x)
            % -------------------------------------------------------------
            tf = isSubclass(x, 'aod.core.Entity');
        end
    end
end 