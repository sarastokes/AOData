classdef EntityBox < aod.app.Component
% Interface for viewing entity-specific information
%
% Parent:
%   Component
%
% Constructor:
%   obj = aod.app.query.EntityBox(parent, canvas)
%
% Children:
%   N/A
%
% Events:
%   N/A
%
% TODO: Entity information display

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------


    properties
        entityLayout        matlab.ui.container.GridLayout
        entityLabels
    end

    properties (Dependent)
        isVisible           logical
    end

    methods
        function obj = EntityBox(parent, canvas)
            obj = obj@aod.app.Component(parent, canvas);
        end

        function value = get.isVisible(obj)
            value = obj.Parent.isExpanded && obj.Parent.isVisible;
        end
    end

    methods
        function update(obj, evt)
            switch evt.EventType
                case "SelectedNode"
                    hdfPath = evt.Trigger.Tree.SelectedNodes(1).Tag;
                    entityList = string(strsplit(hdfPath, '/'));
                    idx = cellfun(@(x) isempty(x) || ismember(x, aod.core.EntityTypes.allContainerNames()), entityList);
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
                case "DeselectedNode"
                    obj.reset();
            end
        end

        function reset(obj)
            obj.datasetText.Items = {};
            obj.linkText.Items = {};
            obj.attrTable.Data = [];
        end
    end

    methods (Access = protected)
        function createUi(obj)
            obj.entityLayout = uigridlayout(obj.Canvas, [5, 1],...
                "RowHeight", {"fit"},...
                "RowSpacing", 3, "Padding", [0 0 0 0],...
                "Scrollable", "on");
            labels = [];
            for i = 1:5
                iLabel = uilabel(obj.entityLayout, "Text", "");
                labels = cat(1, labels, iLabel);
            end
            obj.entityLabels = labels;
        end
    end
end 