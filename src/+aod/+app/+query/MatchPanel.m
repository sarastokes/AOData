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
        entityTree 
        entityBox

        matchLayout         matlab.ui.container.GridLayout
        expandButton        matlab.ui.control.Button
        entityLabel         matlab.ui.control.Label
    end

    methods 
        function obj = MatchPanel(parent, canvas)
            obj = obj@aod.app.Component(parent, canvas);
            obj.isExpanded = false;
            obj.isVisible = true;
        end
    end

    methods
        function update(obj, varargin)
            if nargin > 1
                evt = varargin{1};
                if evt.EventType == "TabHidden"
                    obj.isVisible = false;
                elseif evt.EventType == "TabActive"
                    obj.isVisible = true;
                end
            end

            if obj.isVisible
                obj.updateChildren(varargin{:});
            end
        end
    end

    methods
        function expand(obj)
            if obj.isExpanded
                return
            end
            set(obj.expandButton,... 
                "Text", "Minimize", "Icon", obj.getIcon("expand"));
            obj.matchLayout.RowHeight = {"1x", "fit", "0.5x"};
            obj.entityBox.entityLayout.Scrollable = "on";
            obj.isExpanded = true;
        end

        function collapse(obj)
            if ~obj.isExpanded
                return 
            end
            set(obj.expandButton,...
                "Text", "Expand", "Icon", obj.getIcon("collapse"));
            obj.matchLayout.RowHeight = {"1x", "fit", 0.1};
            obj.entityBox.entityLayout.Scrollable = "off";
            obj.isExpanded = false;
        end
    end

    methods (Access = protected)
        function value = specifyChildren(obj)
            value = [obj.entityBox; obj.entityTree];
        end

        function createUi(obj)
            obj.matchLayout = uigridlayout(...
                aod.app.util.uilayoutfill(obj.Canvas), [3 1],...
                "RowHeight", {"1x", "fit", 0.1},...
                "RowSpacing", 3,...
                "Padding", [5 5 5 5]);
            obj.entityTree = aod.app.query.EntityTree(obj, obj.matchLayout);
            expandLayout = uigridlayout(obj.matchLayout, [1 2],...
                "ColumnWidth", {"fit", "1x"}, "RowHeight", {"fit"},...
                "Padding", [0 0 0 0]);
            obj.expandButton = uibutton(expandLayout,...
                "Text", "Expand", "Icon", obj.getIcon("collapse"),...
                "ButtonPushedFcn", @obj.onPush_Expand);
            obj.entityLabel = uilabel(expandLayout,...
                "Text", "0 matched entities",...
                "HorizontalAlignment", "left");
            obj.entityBox = aod.app.query.EntityBox(obj, obj.matchLayout);
        end

        function onPush_Expand(obj, src, ~)
            if src.Text == "Expand"
                obj.expand();
            else
                obj.collapse();
            end
        end
    end
end 