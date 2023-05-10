classdef Component < handle & matlab.mixin.Heterogeneous
% Base component for user interface building
%
% Parent:
%   handle, matlab.mixin.Heterogeneous
%
% Constructor:
%   obj = aod.app.Component(parent, canvas)
%
% Subclassable methods:
%   - update(obj, varargin)
%   - value = specifyChildren(obj)
%   - createUi(obj)
%
% See also:
%   aod.app.EventHandler, aod.app.Event

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    events
        NewEvent
    end

    properties (SetAccess = private)  
        % Parent Component, if present
        Parent 
        % Graphics container for creating UI
        Canvas    
        % EventHandler for passing actions to other components
        Handler             
    end

    properties (Dependent)
        Root
        Children 
    end

    properties (Hidden, Constant)
        TEXT_HEIGHT = 20;
        BUTTON_WIDTH = 30;
        FILTER_HEIGHT = 55;
    end

    methods (Abstract, Access = protected)
        createUi(obj)
    end

    methods
        function obj = Component(parent, canvas)
            obj.Parent = parent;
            obj.Canvas = canvas;

            obj.createUi();
        end

        function value = get.Children(obj)
            value = obj.specifyChildren();
        end

        function value = get.Root(obj)
            if isempty(obj.Parent)
                value = [];
                return
            end

            value = obj.Parent;
            while ~isempty(value.Parent)
                value = value.Parent;
            end
        end
    end

    methods
        function update(obj, varargin)
            % Top-down information flow
            obj.updateChildren(varargin{:});
        end

        function publish(obj, eventName, varargin)
            evtData = aod.app.Event(eventName, varargin{:});
            notify(obj, 'NewEvent', evtData);
        end
    end

    methods (Access = protected)
        function value = specifyChildren(obj)
            value = [];
        end
    end

    methods (Sealed, Access = protected)
        function updateChildren(obj, varargin)
            if ~isempty(obj.Children)
                arrayfun(@(x) x.update(varargin{:}), obj.Children);
            end
        end
    end

    methods (Access = ?aod.app.Component)
        function setHandler(obj, evtHandler)
            arguments
                obj
                evtHandler aod.app.EventHandler
            end

            obj.Handler = evtHandler;
        end
    end

    methods (Static)       
        function iconPath = getIcon(name)
            name = convertCharsToStrings(name);
            iconPath = aod.app.util.getIconFolder();

            switch name 
                case "add"
                    icon = "add.png";
                case "cancel"
                    icon = "cancel.png";
                case "check"
                    icon = "checked-checkbox.png";
                case "collapse"
                    icon = "collapse-arrow.png";
                case "copy"
                    icon = "copy.png";
                case "dropdown"
                    icon = "dropdown-field.png";
                case "edit"
                    icon = "edit.png";
                case {"editfield", "editbox"}
                    icon = "rename.png";
                case "expand"
                    icon = "expand-arrow.png";
                case 'filter'
                    icon = 'filter.png';
                case "folder"
                    icon = "folder.png";
                case "home"
                    icon = "home-page.png";
                case "puzzle"
                    icon = "puzzle.png";
                case "refresh"
                    icon = "refresh.png";
                case "remove"
                    icon = "do-not-disturb.png";
                case "save"
                    icon = "save.png";
                case "search"
                    icon = "search.png";
                case "tree"
                    icon = "tree-structure.png";
                otherwise
                    warning('getIcon:InvalidInput',...
                        'Icon %s not found', name);
                    iconPath = [];
                    return 
            end
            iconPath = iconPath + icon;
        end
    end
end 