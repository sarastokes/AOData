classdef EntityBox < aod.app.Component
% Interface for viewing entity-specific information
%
% Parent:
%   aod.app.Component
%
% Constructor:
%   obj = aod.app.query.EntityBox(parent, canvas)
%
% Children:
%   N/A
%
% Events:
%   OpenViewer

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------


    properties
        entityLayout        matlab.ui.container.GridLayout
        entityLabels        matlab.ui.control.Label
        viewerButton        matlab.ui.control.Button
    end

    properties (Dependent)
        isVisible           logical
    end

    methods
        function obj = EntityBox(parent, canvas)
            obj = obj@aod.app.Component(parent, canvas);
            obj.setHandler(aod.app.EventHandler(obj));
        end

        function value = get.isVisible(obj)
            value = obj.Parent.isExpanded && obj.Parent.isVisible;
        end
    end

    methods
        function reset(obj)
            arrayfun(@(x) set(x, "Text", ""), obj.entityLabels);
            set(obj.viewerButton, "Tag", hdfPath, "Enable", "off");
        end

        function update(obj, evt)
            switch evt.EventType
                case "SelectedNode"
                    hdfPath = evt.Trigger.Tree.SelectedNodes(1).Tag;
                    entityList = string(strsplit(hdfPath, '/'));
                    idx = cellfun(@(x) isempty(x) || ismember(x, aod.common.EntityTypes.allContainerNames()), entityList);
                    entityList(idx) = [];
                    for i = 1:5
                        if i > numel(entityList)
                            obj.entityLabels(i).Text = "";
                        elseif i == 1
                            obj.entityLabels(i).Text = entityList(i);
                        else
                            obj.entityLabels(i).Text = ...
                                string(repmat('-- ', [1, i-1])) + entityList(i);
                        end
                        if i == numel(entityList)
                            obj.entityLabels(i).FontWeight = "bold";
                        else
                            obj.entityLabels(i).FontWeight = "normal";
                        end
                    end
                    set(obj.viewerButton, "Tag", hdfPath, "Enable", "on");
                case "DeselectedNode"
                    obj.reset();
            end
        end
    end

    methods (Access = private)
        function onPush_OpenAODataViewer(obj, src, ~)
            obj.publish("OpenViewer", obj,...
                "HdfPath", src.Tag);
        end
    end

    methods (Access = protected)
        function createUi(obj)
            obj.entityLayout = uigridlayout(obj.Canvas, [6, 1],...
                "RowHeight", {"fit"},...
                "RowSpacing", 1, "Padding", [0 0 0 0],...
                "Scrollable", "on");
            labels = [];
            for i = 1:5
                iLabel = uilabel(obj.entityLayout, "Text", "");
                labels = cat(1, labels, iLabel);
            end
            obj.entityLabels = labels;

            obj.viewerButton = uibutton(obj.entityLayout,...
                "Text", "Open in AODataViewer",...
                "Icon", obj.getIcon("window"),...
                "Enable", "off",...
                "ButtonPushedFcn", @obj.onPush_OpenAODataViewer);
        end
    end
end 