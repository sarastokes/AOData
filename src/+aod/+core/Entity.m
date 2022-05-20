classdef Entity < handle 
%
% Methods:
%   addParameter(obj, name, value)
%   value = getParameter(obj, name)
%   addNote(obj, txt)
%   removeNote(obj, ID)
%   clearNotes(obj)
%
% Protected Methods:
%   getShortName
%   getDisplayName
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
            obj.parameters(paramName) = paramValue;
        end

        function value = getParameter(obj, paramName)
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
            if obj.isValidParent(parent)
                obj.Parent = parent;
            else
                error('%s is not a valid parent', class(parent));
            end
        end
    end

    methods (Access = private)
        function tf = isValidParent(obj, parent)
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