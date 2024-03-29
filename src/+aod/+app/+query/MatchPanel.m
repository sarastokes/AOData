classdef MatchPanel < aod.app.Component 
% Container for exploring entities that match the query
%
% Superclass:
%   Component
%
% Constructor:
%   obj = aod.app.query.MatchPanel(parent, canvas)
%
% Children:
%   EntityTree, EntityBox
%
% Events:
%   N/A

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        isExpanded          logical
        isVisible           logical
    end

    properties
        entityTree          % aod.app.query.EntityTree
        entityBox           % aod.app.query.EntityBox

        matchLayout         matlab.ui.container.GridLayout
        expandButton        matlab.ui.control.Button
        entityLabel         matlab.ui.control.Label
    end

    methods 
        function obj = MatchPanel(parent, canvas)
            obj = obj@aod.app.Component(parent, canvas);
            obj.isExpanded = false;
            obj.isVisible = true;

            obj.setHandler(aod.app.query.handlers.MatchPanel(obj));
        end
    end

    % Local helper methods
    methods (Access = private)
        function showEntityCount(obj)
            obj.entityLabel.Text = ...
                sprintf("Total entities (%u)", obj.Root.numEntities);
        end
    end

    % Callback methods
    methods (Access = private)
        function onPush_Expand(obj, src, ~)
            if src.Text == "Expand"
                set(obj.expandButton, ...
                    "Text", "Minimize", "Icon", obj.getIcon("expand"));
                obj.matchLayout.RowHeight = {"1x", "fit", "0.7x"};
                obj.entityBox.entityLayout.Scrollable = "on";
                obj.isExpanded = true;
            else
                set(obj.expandButton, ...
                    "Text", "Expand", "Icon", obj.getIcon("collapse"));
                obj.matchLayout.RowHeight = {"1x", "fit", 0.1};
                obj.entityBox.entityLayout.Scrollable = "off";
                obj.isExpanded = false;
            end
        end
    end

    % Component methods (protected)
    methods
        function update(obj, evt)

            if evt.EventType == "TabHidden"
                obj.isVisible = false;
            elseif evt.EventType == "TabActive"
                obj.isVisible = true;
            end

            % This isn't costly, do it regardless of whether the component
            % is active and then let child components implement isDirty
            if ismember(evt.EventType, ["AddExperiment", "RemoveExperiment"])
                obj.showEntityCount();
            end

            obj.updateChildren(evt);
        end
    end

    % Component methods (protected)
    methods (Access = protected)
        function value = specifyChildren(obj)
            value = [obj.entityBox; obj.entityTree];
        end

        function createUi(obj)
            obj.matchLayout = uigridlayout(...
                aod.app.util.uilayoutfill(obj.Canvas), [3 1],...
                "RowHeight", {"1x", "fit", 0.1},...
                "RowSpacing", 2,...
                "Padding", [5 5 5 5]);

            obj.entityTree = aod.app.query.EntityTree(obj, obj.matchLayout);
            
            expandLayout = uigridlayout(obj.matchLayout, [1 2],...
                "ColumnWidth", {"fit", "1x"}, "RowHeight", {"fit"},...
                "Padding", [0 0 0 0]);
            obj.expandButton = uibutton(expandLayout,...
                "Text", "Expand", "Icon", obj.getIcon("collapse"),...
                "ButtonPushedFcn", @obj.onPush_Expand);
            obj.entityLabel = uilabel(expandLayout,...
                "Text", "0 matched entities (0 total)",...
                "HorizontalAlignment", "left");
            if obj.Root.numExperiments ~= 0
                obj.showEntityCount();
            end
            
            obj.entityBox = aod.app.query.EntityBox(obj, obj.matchLayout);
        end
    end
end 