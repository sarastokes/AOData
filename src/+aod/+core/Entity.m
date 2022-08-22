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
%   description                 string
%   notes                       cell
%   allowableParentTypes        cellstr
%
% Dependent properties:
%   label                       string      (defined by getLabel)
%   shortName                   string      (defined by shortName)
%
% Public:
%   h = ancestor(obj, className)
%   setDescription(obj, txt, overwrite)
%   addNote(obj, txt)
%   clearNotes(obj)
%   setParam(obj, varargin)
%   value = getParam(obj, paramName, mustReturnParam)
%   tf = hasParam(obj, paramName)
%
% Protected methods:
%   x = getShortName(obj)
%   x = getLabel(obj)
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
        UUID                        string = string.empty()
        description                 string = string.empty() 
        notes                       string = string.empty()
    end

    properties (SetAccess = protected)
        parameters                  % aod.core.Parameters()
    end

    
    properties (Abstract, Hidden, SetAccess = protected)
        allowableParentTypes        cell
        % parameterPropertyName       char
    end

    properties (Dependent)
        label
    end

    properties (Hidden, Dependent)
        shortName
    end

    methods
        function obj = Entity(parent)
            if nargin > 0
                obj.setParent(parent);
            end
            obj.UUID = aod.util.generateUUID();
            obj.parameters = aod.core.Parameters();
        end

        function value = get.label(obj)
            value = obj.getLabel();
        end

        function value = get.shortName(obj)
            value = obj.getShortName();
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
            % tf = obj.(obj.parameterPropertyName).isKey(paramName);
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
                % paramProp = obj.(obj.parameterPropertyName);
                % paramValue = paramProp(paramName);
                paramValue = obj.parameters(paramName);
            else
                switch msgType 
                    case MessageTypes.ERROR 
                        error('GetParam: Did not find %s in parameters',... 
                            paramName, obj.parameterPropertyName);
                    case MessageTypes.WARNING 
                        warning('GetParam: Did not find %s in parameters',... 
                            paramName);
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
            %   Add parameter(s) to the parameter property defined by
            %   parameterPropertyName
            %
            % Syntax:
            %   obj.setParam(paramName, value)
            %   obj.setParam(paramName1, value1, paramName2, value2)
            %   obj.setParam(struct)
            % -------------------------------------------------------------
            if nargin == 1
                return
            end
            %paramProp = obj.(obj.parameterPropertyName);

            if nargin == 2 && isstruct(varargin{1})
                S = varargin{1};
                k = fieldnames(S);
                for i = 1:numel(k)
                    % paramProp(k{i}) = S.(k{i});
                    obj.parameters(k{i}) = S.(k{i});
                end
            else
                for i = 1:(nargin - 1)/2
                    % paramProp(varargin{(2*i)-1}) = varargin{2*i};
                    obj.parameters(varargin{(2*i)-1}) = varargin{2*i};
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
            value = getClassWithoutPackages(obj);
        end

        function shortName = getShortName(obj)
            % GETSHORTNAME
            % 
            % Syntax:
            %   shortName = obj.getShortName()
            % -------------------------------------------------------------
            shortName = obj.getLabel();
        end
    end

    methods (Sealed, Access = {?aod.core.Entity, ?aod.core.Creator})
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