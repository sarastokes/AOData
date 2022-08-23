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
%   parameters                  aod.core.Parameters
%   files                       aod.core.Files
%   description                 string
%   notes                       cell
%
% Abstract protected properties:
%   allowableParentTypes        cellstr
%
% Dependent properties:
%   label                       string      (defined by getLabel)
%   shortLabel                  string      (defined by getShortLabel)
%
% Public methods:
%   h = ancestor(obj, className)
%   setName(obj, name)
%   setDescription(obj, txt, overwrite)
%   addNote(obj, txt)
%   clearNotes(obj)
%
%   setParam(obj, varargin)
%   value = getParam(obj, paramName, mustReturnParam)
%   tf = hasParam(obj, paramName)
%   removeParam(obj, paramName)
%   
%   setFile(obj, fileName, filePath)
%   value = getFile(obj, fileName, mustReturnFile)
%   tf = hasFile(obj, fileName)
%   removeFile(obj, fileName)
%
% Protected methods:
%   value = getLabel(obj)
%   value = getShortLabel(obj)
%
% Protected methods (with Creator access):
%   addParent(obj, parent)
%   setUUID(obj, uuid)
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
        files                       = aod.core.Parameters()
        parameters                  = aod.core.Parameters()
    end
    
    properties (Abstract, Hidden, SetAccess = protected)
        allowableParentTypes        cell
    end

    properties (Dependent)
        label
    end

    properties (Hidden, Dependent)
        shortLabel
    end

    methods
        function obj = Entity(parent, name)
            if nargin > 0
                obj.setParent(parent);
            end
            if nargin > 1
                obj.setName(name);
            end
            obj.UUID = aod.util.generateUUID();
        end

        function value = get.label(obj)
            value = obj.getLabel();
        end

        function value = get.shortLabel(obj)
            value = obj.getShortLabel();
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
            if ~isempty(obj.notes)
                obj.notes = obj.notes + '; ';
            end
            obj.notes = obj.notes + txt;
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
            if isprop(obj, 'homeDirectory') && ~isempty(obj.homeDirectory)
                filePath = erase(filePath, obj.homeDirectory);
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
    end

    % Methods likely to be overwritten by subclasses
    methods (Access = protected)
        function value = getLabel(obj)  
            % GETLABEL
            %      
            % Syntax:
            %   value = obj.getLabel()
            % -------------------------------------------------------------
            if isempty(obj.Name)
                value = getClassWithoutPackages(obj);
            else
                value = obj.Name;
            end
        end

        function value = getShortLabel(obj)
            % GETSHORTLABEL
            % 
            % Syntax:
            %   value = getShortLabel(obj)
            % -------------------------------------------------------------
            value = obj.getLabel();
        end
    end

    methods (Sealed, Access = protected)
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