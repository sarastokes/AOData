classdef (Abstract) Entity < handle 
% ENTITY
%
% Constructor:
%   obj = aod.core.Entity()
%
% Properties:
%   Parent                      aod.core.Entity
%   parameters                  containers.Map()
%   notes                       cell
%   allowableParentTypes        cellstr
%   allowableChildTypes         cellstr
%
% Dependent properties:
%   displayName                 string
%   shortName                   string
%
% Methods:
%   addParameter(obj, name, value)
%   value = getParameter(obj, name)
%   addNote(obj, txt)
%   removeNote(obj, ID)
%   clearNotes(obj)
%
% Protected Methods:
%   addParent(obj, parent)
%   x = getShortName(obj)
%   x = getDisplayName(obj)
%   addParserToParams(obj, S)
%
% Private methods:
%   tf = isValidParent(obj, parent)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Parent
        parameters
        notes = cell.empty();
    end

    
    properties (Hidden, SetAccess = protected)
        allowableParentTypes = cell.empty();
        allowableChildTypes = cell.empty();
    end

    properties (Dependent = true)
        displayName
        shortName
    end

    methods
        function obj = Entity()
            obj.parameters = containers.Map();
        end

        function value = get.displayName(obj)
            value = obj.getDisplayName();
        end

        function value = get.shortName(obj)
            value = obj.getShortName();
        end
    end

    methods 
        function addParameter(obj, paramName, paramValue)
            % ADDPARAMETER
            %
            % Syntax:
            %   obj.addParameter(paramName, paramValue)
            % -------------------------------------------------------------
            obj.parameters(paramName) = paramValue;
        end

        function value = getParameter(obj, paramName)
            % GETPARAMETER
            %
            % Syntax:
            %   value = obj.getParameter(paramName)
            % -------------------------------------------------------------
            if ~isKey(obj.parameters, paramName)
                error('Parameter %s not found!', paramName);
            end
            value = obj.parameter(paramName);
        end
        
        function addNote(obj, txt)
            % ADDNOTE
            % 
            % Syntax:
            %   obj.addNote(txt)
            % -------------------------------------------------------------
            obj.notes = cat(1, obj.notes, txt);
        end

        function removeNote(obj, noteID)
            % REMOVENOTE
            %
            % Syntax:
            %   obj.removeNote(noteID)
            % -------------------------------------------------------------
            if noteID > numel(obj.notes)
                error('Note %u is invalid. %u notes exist',... 
                    noteID, numel(obj.notes));
            end
            obj.notes{noteID} = [];
        end

        function clearNotes(obj)
            % CLEARNOTES
            %
            % Syntax:
            %   obj.clearNotes();
            % -------------------------------------------------------------
            obj.notes = cell(0,1);
        end
    end

    % Methods likely to be overwritten by subclasses
    methods (Access = protected)
        function displayName = getDisplayName(obj)  
            % GETDISPLAYNAME
            %      
            % Syntax:
            %   displayName = obj.getDisplayName()
            % -------------------------------------------------------------
            displayName = ao.util.class2char(obj);
        end


        function shortName = getShortName(obj)
            % GETSHORTNAME
            % 
            % Syntax:
            %   shortName = obj.getShortName()
            % -------------------------------------------------------------
            shortName = obj.getDisplayName();
        end

    end

    methods (Access = protected)
        function setParent(obj, parent)
            % SETPARENT
            %   
            % Syntax:
            %   obj.setParent(parent)
            % -------------------------------------------------------------
            if obj.isValidParent(parent)
                obj.Parent = parent;
            else
                error('%s is not a valid parent', class(parent));
            end
        end

        function addParserToParams(obj, S)
            % ADDPARSERTOPARAMS
            %
            % Syntax:
            %   obj.addParserToParams(S)
            %
            % Input:
            %   S       struct
            %       The "Results" structure from inputParser
            %
            % See also:
            %   inputParser
            % -------------------------------------------------------------
            f = fieldnames(S);
            for i = 1:numel(f)
                obj.parameters(f{i}) = S.(f{i});
            end
        end
    end

    methods (Access = private)
        function tf = isValidParent(obj, parent)
            % ISVALIDPARENT
            %
            % Syntax:
            %   tf = isValidParent(parent)
            % -------------------------------------------------------------
            if isempty(obj.allowableParentTypes)
                tf = true;
            elseif ismember(class(parent), obj.allowableParentTypes)
                tf = true;
            else
                tf = false;
            end
        end
    end
end 