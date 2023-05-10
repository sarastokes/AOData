classdef FilterControls < aod.app.Component 
% Buttons for adding, removing, editing and checking filters
%
% Superclass:
%   aod.app.Component
%
% Constructor:
%   obj = aod.app.query.FilterControls(parent, canvas, isSubfilter)
%
% Children:
%   N/A
%
% Events:
%   PushFilter, PullFilter, CheckFilter, EditFilter,...
%   PushSubfilter, PullSubfilter, CheckSubfilter, EditSubfilter

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    %% TODO: Needs filterID
    properties (SetAccess = private)
        isSubfilter         logical 
    end

    properties 
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

            obj.setHandler(aod.app.query.handlers.FilterControls(obj));
        end
    end

    methods
        function update(obj, varargin)
            if nargin == 2
                evt = varargin{1};
            end

            if strcmp(evt.EventType, "ChangedFilterInput")
                if evt.Data.Ready
                    obj.checkButton.Enable = "on";
                    obj.addButton.Enable = "on";
                else
                    obj.checkButton.Enable = "off";
                    obj.addButton.Enable = "off";
                end
            elseif strcmp(evt.EventType, "ChangeFilterType")
                obj.checkButton.Enable = "off";
                obj.addButton.Enable = "off";
            end
        end

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
                "Text", "", "Tag", "PushFilter",...
                "Icon", obj.getIcon("add"),...
                "Enable", "off",...
                "ButtonPushedFcn", @obj.onPush_Button);
            obj.removeButton = uibutton(buttonLayout,...
                "Text", "", "Tag", "PullFilter",...
                "Icon", obj.getIcon('cancel'),...
                "ButtonPushedFcn", @obj.onPush_Button);
            obj.editButton = uibutton(buttonLayout,...
                "Text", "", "Tag", "EditFilter",...
                "Icon", obj.getIcon('edit'),...
                "Enable", "off",...
                "ButtonPushedFcn", @obj.onPush_Button);
            obj.checkButton = uibutton(buttonLayout,...
                "Text", "", "Tag", "CheckFilter",...
                "Icon", obj.getIcon('check'),...
                "Enable", "off",...
                "ButtonPushedFcn", @obj.onPush_Button);
        end

        function onPush_Button(obj, src, evt)
            if obj.isSubfilter
                eventName = strrep(src.Tag, "Filter", "Subfilter");
                subID = obj.Parent.subID;
            else
                eventName = src.Tag;
                subID = [];
            end
            disp(eventName);
            
            obj.publish(eventName, obj,...
                "ID", obj.Parent.ID, "SubID", subID);
        end
    end
end 