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
%
% Notes:
%   FilterControls are a separate class for clarity but communicate with  
%   the larger UI as their parent FilterBox or SubfilterBox.

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        % Whether the controls are attached to a subfilter or not
        isSubfilter         logical 
        % Whether the Parent filter has been added to QueryManager
        isAdded             logical
    end

    properties 
        gridLayout          matlab.ui.container.GridLayout
        addButton           matlab.ui.control.Button
        checkButton         matlab.ui.control.Button
        editButton          matlab.ui.control.Button
        removeButton        matlab.ui.control.Button
    end

    methods 
        function obj = FilterControls(parent, canvas, isSubfilter)
            if nargin < 3
                isSubfilter = false;
            end
            obj = obj@aod.app.Component(parent, canvas, isSubfilter);
            obj.isAdded = false;

            obj.setHandler(aod.app.EventHandler(obj));
        end
    end

    % Component methods
    methods
        function update(obj, evt)
            switch evt.EventType 
                case "ChangedFilterInput"
                    if evt.Data.Ready
                        if obj.isAdded
                            obj.checkButton.Enable = "on";
                        else
                            obj.addButton.Enable = "on";
                        end
                    else
                        if obj.isAdded
                            obj.checkButton.Enable = "off";
                        else
                            obj.addButton.Enable = "off";
                        end
                    end
                case "ChangeFilterType"
                    obj.checkButton.Enable = "off";
                    obj.addButton.Enable = "off";
                case "PushFilter"
                    obj.isAdded = true;
                    obj.removeButton.Enable = "on";
                    obj.addButton.Enable = "off";
                    obj.editButton.Enable = "on";
                    obj.checkButton.Enable = "off";
                case "PullFilter"
                    obj.isAdded = false;
                case "EditFilter"
                    obj.editButton.Enable = "off";
                    obj.removeButton.Enable = "on";
                    obj.addButon.Enable = "off";
                    obj.checkButton.Enable = "on";
                case "CheckFilter"
                    obj.editButton.Enable = "on";
                    obj.removeButton.Enable = "on";
                    obj.checkButton.Enable = "off";
                    obj.addButton.Enable = "off";
            end
        end
    end

    methods (Access = protected)
        function willGo(obj, varargin)
            obj.isSubfilter = varargin{1};
        end

        function createUi(obj)
            obj.gridLayout = uigridlayout(obj.Canvas, [2 2],...
                "RowSpacing", 2, "ColumnSpacing", 2,...
                "Padding", [5 5 5 5]);
            obj.addButton = uibutton(obj.gridLayout,...
                "Text", "", "Tag", "PushFilter",...
                "Icon", obj.getIcon("add"),...
                "Enable", "off",...
                "ButtonPushedFcn", @obj.onPush_Button);
            obj.removeButton = uibutton(obj.gridLayout,...
                "Text", "", "Tag", "PullFilter",...
                "Enable", "on",...
                "Icon", obj.getIcon('cancel'),...
                "ButtonPushedFcn", @obj.onPush_Button);
            obj.editButton = uibutton(obj.gridLayout,...
                "Text", "", "Tag", "EditFilter",...
                "Icon", obj.getIcon('edit'),...
                "Enable", "off",...
                "ButtonPushedFcn", @obj.onPush_Button);
            obj.checkButton = uibutton(obj.gridLayout,...
                "Text", "", "Tag", "CheckFilter",...
                "Icon", obj.getIcon('check'),...
                "Enable", "off",...
                "ButtonPushedFcn", @obj.onPush_Button);
        end

        function close(obj)
            delete(obj.gridLayout);
        end
    end

    methods (Access = private)
        function onPush_Button(obj, src, ~)
            if obj.isSubfilter
                eventName = strrep(src.Tag, "Filter", "Subfilter");
                subID = obj.Parent.subID;
            else
                eventName = src.Tag;
                subID = [];
            end
            disp(eventName);
            
            obj.publish(eventName, obj.Parent,...
                "ID", obj.Parent.ID, "SubID", subID);
        end
    end
end 