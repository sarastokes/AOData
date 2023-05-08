classdef MatchPanel < aod.app.Component 
%
% Parent:
%   Component
%
% Constructor:
%   obj = aod.app.query.MatchPanel(parent, canvas)
%
% Children:
%   EntityTree, EntityBox

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    events 
        PanelExpanded
        PanelMinimized
    end

    properties 
        isExpanded          logical
    end

    properties
        entityTree 
        entityBox

        matchLayout         matlab.ui.container.GridLayout
        expandButton        matlab.ui.control.Button
        entityLabel         matlab.ui.control.Label
    end

    methods 
        function obj = MatchPanel(parent, canvas)
            obj = obj@aod.app.Component(parent, canvas);
            obj.isExpanded = true;
        end
    end

    methods (Access = protected)
        function value = specifyChildren(obj)
            value = [obj.entityBox; obj.entityTree];
        end

        function createUi(obj)
            obj.matchLayout = uigridlayout(...
                aod.app.util.uilayoutfill(obj.Canvas), [3 1],...
                "RowHeight", {"1x", "fit", "0.5x"},...
                "RowSpacing", 3,...
                "Padding", [5 5 5 5]);
            obj.entityTree = aod.app.query.EntityTree(obj, obj.matchLayout);
            expandLayout = uigridlayout(obj.matchLayout, [1 2],...
                "ColumnWidth", {"fit", "1x"}, "RowHeight", {"fit"},...
                "Padding", [0 0 0 0]);
            obj.expandButton = uibutton(expandLayout,...
                "Text", "Minimize", "Icon", [],...
                "ButtonPushedFcn", @obj.onPush_Expand);
            obj.entityLabel = uilabel(expandLayout,...
                "Text", "0 matched entities",...
                "HorizontalAlignment", "left");
            obj.entityBox = aod.app.query.EntityBox(obj, obj.matchLayout);
        end

        function onPush_Expand(obj, src, ~)
            if src.Text == "Minimize"
                src.Text = "Expand";
                obj.matchLayout.RowHeight = {"1x", 30, 0.1};
                obj.entityBox.entityLayout.Scrollable = "off";
            else
                obj.matchLayout.RowHeight = {"1x", obj.TEXT_HEIGHT, "0.5x"};
                src.Text = "Minimize";
                obj.entityBox.entityLayout.Scrollable = "on";
            end
        end
    end
end 