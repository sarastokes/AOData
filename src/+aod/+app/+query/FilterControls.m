classdef FilterControls < aod.app.Component 
% Buttons for adding, removing, editing and checking filters
%
% Parent:
%   Component
%
% Constructor:
%   obj = aod.app.query.FilterControls(parent, canvas, isSubfilter)
%
% Children:
%   N/A

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    events 
        AddFilter
        CheckFilter
        EditFilter
        RemoveFilter 
    end

    properties
        isSubfilter         logical 

        addButton           matlab.ui.control.Button
        checkButton         matlab.ui.control.Button
        editButton          matlab.ui.control.Button
        removeButton        matlab.ui.control.Button
    end

    methods 
        function obj = FilterControls(parent, canvas, isSubfilter)
            obj = obj@aod.app.Component(parent, canvas);
            if nargin < 3
                isSubfilter = false;
            end
            obj.isSubfilter = isSubfilter;
        end
    end

    methods
        function filterAdded(obj)
            obj.addButton.Enable = "off";
            obj.editButton.Enable = "on";
            obj.checkButton.Enable = "off";
            obj.removeButton.Enable = "on";
        end

        function filterEdited(obj)
            obj.addButton.Enable = "on";
            obj.editButton.Enable = "off";
            obj.removeButton.Enable = "on";
            obj.checkButton.Enable = "on";
        end
    end

    methods (Access = protected)
        function createUi(obj)
            buttonLayout = uigridlayout(obj.Canvas, [2 2],...
                "RowSpacing", 2, "ColumnSpacing", 2,...
                "Padding", [5 5 5 5]);
            obj.addButton = uibutton(buttonLayout,...
                "Text", "", "Tag", "AddFilter",...
                "Icon", obj.getIcon("add"),...
                "ButtonPushedFcn", @obj.onButtonPushed);
            obj.removeButton = uibutton(buttonLayout,...
                "Text", "", "Tag", "RemoveFilter",...
                "Icon", obj.getIcon('remove'),...
                "ButtonPushedFcn", @obj.onButtonPushed);
            obj.editButton = uibutton(buttonLayout,...
                "Text", "", "Tag", "EditFilter",...
                "Icon", obj.getIcon('edit'),...
                "Enable", "off",...
                "ButtonPushedFcn", @obj.onButtonPushed);
            obj.checkButton = uibutton(buttonLayout,...
                "Text", "", "Tag", "CheckFilter",...
                "Icon", obj.getIcon('check'),...
                "ButtonPushedFcn", @obj.onButtonPushed);
        end

        function onButtonPushed(obj, src, evt)
            if obj.isSubfilter
                eventName = strrep(src.Tag, "Filter", "Subfilter");
            else
                eventName = src.Tag;
            end
            evtData = Event(eventName, obj);
        end
    end
end 