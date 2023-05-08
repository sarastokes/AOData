classdef SubfilterBox < aod.app.Component
%
% Parent:
%   aod.app.Component
%
% Constructor:
%   obj = aod.app.query.SubfilterBox(parent, canvas, ID)
%
% Children:
%   InputBox, FilterControls

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        subID 
    end

    properties (Dependent)
        ID 
    end

    properties 
        gridLayout          matlab.ui.container.GridLayout 
        filterDropdown      matlab.ui.control.DropDown
        inputBox 
        filterControls
    end

    methods
        function obj = SubfilterBox(parent, canvas, ID)
            obj = obj@aod.app.Component(parent, canvas);
            obj.setHandler(aod.app.query.SubfilterBoxHandler(obj));
            obj.subID = ID;
            obj.gridLayout.Layout.Row = obj.subID + 1;
        end

        function value = get.ID(obj)
            value = obj.Parent.ID;
        end

        function setSubfilterID(obj, newID)
            obj.subID = newID;
        end
    end

    methods (Access = protected)
        function value = specifyChildren(obj)
            value = [obj.inputBox; obj.filterControls];
        end
        
        function createUi(obj)
            obj.gridLayout = uigridlayout(obj.Canvas, [1 3],...
                "ColumnWidth", {"1x", "2x", 70},...
                "Padding", [0 0 0 0],...
                "RowHeight", obj.FILTER_HEIGHT,...
                "BackgroundColor", rgb("peach"));
            
            filterLayout = uigridlayout(obj.gridLayout, [2 1],...
                "RowHeight", {obj.TEXT_HEIGHT, "1x"}, "RowSpacing", 2,...
                "Padding", [0 5 0 0]);
            uilabel(filterLayout, "Text", "Filter Type",...
                "FontWeight", "bold", "FontSize", 12,... 
                "HorizontalAlignment", "center",...
                "VerticalAlignment", "center");
            obj.filterDropdown = uidropdown(filterLayout,...
                "Items", [""; getEnumMembers("aod.api.FilterTypes")]',...
                "ValueChangedFcn", @obj.onSelected_FilterDropdown);
            obj.filterDropdown.Items = obj.filterDropdown.Items(...
                ~ismember(obj.filterDropdown.Items, ["LINK", "CHILD", "PARENT"]));
            obj.inputBox = aod.app.query.InputBox(obj, obj.gridLayout);
            obj.filterControls = aod.app.query.FilterControls(obj, obj.gridLayout, true);
        end

        function onSelected_FilterDropdown(obj, src, evt)
        end
    end
end 