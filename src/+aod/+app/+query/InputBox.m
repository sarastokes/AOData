classdef InputBox < aod.app.Component 
% Interface for specification of filter properties
%
% Superclass:
%   aod.app.Component
%
% Constructor:
%   obj = aod.app.query.InputBox(parent, canvas, isSubfilter)
%
% Children:
%   N/A
%
% Events:
%   AddSubfilter, SearchRequest, ChangedFilterInput, ChangedSubfilterInput

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        filterType              = aod.api.FilterTypes.UNDEFINED
        nameProvided            logical
        valueProvided           logical
        isSubfilter             logical 
    end

    properties (Dependent)
        isReady                 logical
    end

    properties
        gridLayout              matlab.ui.container.GridLayout 

        filterLayout            matlab.ui.container.GridLayout
        filterDropdown          matlab.ui.control.DropDown
        filterLabel             matlab.ui.control.Label

        nameLayout              matlab.ui.container.GridLayout
        nameEditfield           matlab.ui.control.EditField
        nameDropdown            matlab.ui.control.DropDown
        nameLabel               matlab.ui.control.Label
        searchButton            matlab.ui.control.Button

        subfilterButton         matlab.ui.control.Button
        valueLayout             matlab.ui.container.GridLayout
        valueEditfield          matlab.ui.control.EditField
        valueLabel              matlab.ui.control.Label
    end

    methods
        function obj = InputBox(parent, canvas, isSubfilter)
            obj = obj@aod.app.Component(parent, canvas);

            if nargin < 3
                obj.isSubfilter = false;
            else
                obj.isSubfilter = isSubfilter;
            end

            obj.setHandler(aod.app.EventHandler(obj));

            obj.nameProvided = false;
            obj.valueProvided = false;
        end

        function value = get.isReady(obj)
            import aod.api.FilterTypes 

            if obj.filterType == FilterTypes.UNDEFINED || ~obj.nameProvided
                value = false;
            else
                value = true;
            end
        end

        function out = getName(obj)
            if obj.nameEditfield.Visible 
                out = obj.nameEditfield.Value;
            else
                out = obj.nameDropdown.Value;
            end
        end

        function out = getValue(obj)
            out = [];

            if obj.valueEditfield.Visible
                out = obj.valueEditfield.Value;
            end
        end
    end

    methods 
        function update(obj, evt)

            switch evt.EventType
                case "PushFilter"
                    obj.toggleEnable("off");
                case "EditFilter"
                    obj.toggleEnable("on");
            end

            obj.updateChildren(evt);
        end

        function toggleEnable(obj, flag)
            arguments
                obj
                flag        string {mustBeMember(flag, ["on" ,"off"])}
            end

            set(obj.filterLayout.Children, "Enable", flag);
            set(obj.nameLayout.Children, "Enable", flag);
            set(obj.valueLayout.Children, "Enable", flag);
        end

        function reset(obj)
            obj.showNameEditfield(" ");
            obj.showValueEditfield();
            obj.hideSearchButton();
            obj.nameEditfield.Value = "";
            obj.nameDropdown.Items = {};
            obj.valueEditfield.Value = "";

            obj.nameProvided = false;
            obj.valueProvided = false;
        end

        function changeFilterType(obj)
            
            obj.reset();

            if obj.filterType == aod.api.FilterTypes.UNDEFINED
                return
            end

            import aod.api.FilterTypes

            switch obj.filterType 
                case FilterTypes.ENTITY
                    obj.nameLabel.Text = "Entity Type";
                    obj.hideValueInput();
                    obj.showNameDropdown();
                    obj.nameDropdown.Items = string(aod.common.EntityTypes.all());
                    obj.searchButton.Visible = "off";
                case FilterTypes.NAME 
                    obj.nameLabel.Text = "Entity Name";
                    obj.showNameEditfield();
                    obj.hideValueInput();
                case FilterTypes.CLASS
                    obj.nameLabel.Text = "Class Name";
                    obj.showNameEditfield();
                    obj.showSearchButton();
                    obj.hideValueInput();
                case {FilterTypes.ATTRIBUTE, FilterTypes.DATASET}
                    obj.nameLabel.Text = "Name";
                    obj.valueLabel.Text = "Value";
                    obj.showValueEditfield("Value");
                case FilterTypes.LINK
                    obj.nameLabel.Text = "Link Name (optional)";
                    obj.showSubfilterButton();
                case FilterTypes.PARENT
                    obj.nameLabel.Text = "Parent Type";
                    obj.nameDropdown.Items = ... 
                        [""; getEnumMembers('aod.api.FilterTypes')]';
                    obj.showSubfilterButton();
                case FilterTypes.CHILD
                    obj.nameLabel.Text = "Child Type";
                    obj.nameDropdown.Items = ... 
                        [""; getEnumMembers('aod.api.FilterTypes')]';
                    obj.showSubfilterButton();
                case FilterTypes.UUID
                    obj.nameLabel.Text = "UUID";
                    obj.hideValueInput();
                case FilterTypes.PATH
                    obj.nameLabel.Text = "HDF5 Path";
                    obj.hideValueInput();
            end
        end
    end

    methods
        function setValueLabel(obj, txt)
            obj.valueLabel.Text = txt;
        end

        function showSubfilterButton(obj)
            obj.valueLabel.Text = "(optional)";
            obj.valueEditfield.Visible = "off";
            obj.subfilterButton.Visible = "on";
        end

        function showNameDropdown(obj)
            obj.nameEditfield.Visible = "off";
            obj.nameDropdown.Visible = "on";
            obj.searchButton.Icon = obj.getIcon("editfield");
        end

        function showNameEditfield(obj, lbl)
            if nargin == 2
                obj.nameLabel.Text = lbl;
            end
            obj.nameDropdown.Visible = "off";
            obj.nameEditfield.Visible = "on";
            obj.searchButton.Icon = obj.getIcon("search");
        end

        function showValueEditfield(obj, label)
            if nargin < 2
                label = "";
            end
            obj.valueLabel.Text = label;  
            obj.subfilterButton.Visible = "off";
            obj.valueEditfield.Visible = "on";
        end

        function showSearchButton(obj)
            obj.searchButton.Visible = "on";
            obj.nameLayout.ColumnWidth = {"1x", obj.BUTTON_WIDTH};
        end

        function hideSearchButton(obj)
            obj.searchButton.Visible = "off";
            obj.nameLayout.ColumnWidth = {"1x", 1};
        end

        function hideValueInput(obj)
            obj.valueLabel.Visible = "off";
            obj.subfilterButton.Visible = "off";
            obj.valueEditfield.Visible = "off";
        end
    end

    methods (Access = protected)
        function createUi(obj)
            obj.gridLayout = uigridlayout(obj.Canvas, [1 2],...
                "ColumnWidth", {"fit", "1x", "1x"}, "RowHeight",  {"1x"},...
                "Padding", [0 0 0 0], "ColumnSpacing", 2);

            % All parameters for input gridlayouts
            gridSpecs = {"RowHeight", {obj.TEXT_HEIGHT, "1x"},...
                "ColumnWidth", {"1x", obj.BUTTON_WIDTH},...
                "RowSpacing", 2, "ColumnSpacing", 2, "Padding", [0 5 0 0]};
            labelSpecs = {"FontSize", 12, "FontWeight", "bold",...
                "HorizontalAlignment", "center",...
                "VerticalAlignment", "center"};

            % INPUT ONE ---------------------------------------------------
            obj.filterLayout = uigridlayout(obj.gridLayout, [2 2], gridSpecs{:});
            obj.filterLayout.Layout.Row = 1;
            obj.filterLayout.Layout.Column = 1;
            
            obj.filterLabel = uilabel(obj.filterLayout,... 
                "Text", "Filter Type", labelSpecs{:});
            obj.filterLabel.Layout.Column = [1 2];

            obj.filterDropdown = uidropdown(obj.filterLayout, ...
                "Items", getEnumMembers("aod.api.FilterTypes")', ...
                "ValueChangedFcn", @obj.onSelected_FilterDropdown);
            obj.filterDropdown.Layout.Column = [1 2];

            % INPUT TWO ---------------------------------------------------
            obj.nameLayout = uigridlayout(obj.gridLayout, [2 2], gridSpecs{:});
            obj.nameLayout.Layout.Column = 2;
            obj.nameLayout.Layout.Row = 1;

            obj.nameLabel = uilabel(obj.nameLayout,... 
                "Text", "", labelSpecs{:});
            obj.nameLabel.Layout.Row = 1;
            obj.nameLabel.Layout.Column = [1 2];

            obj.nameDropdown = uidropdown(obj.nameLayout,... 
                "Items", {}, "Visible", "off",...
                "ValueChangedFcn", @obj.onSelect_Name);
            obj.nameDropdown.Layout.Row = 2;
            obj.nameDropdown.Layout.Column = 1;

            obj.nameEditfield = uieditfield(obj.nameLayout,...
                "Value", "", "Visible", "off",...
                "ValueChangedFcn", @obj.onEdit_Name);
            obj.nameEditfield.Layout.Row = 2;
            obj.nameEditfield.Layout.Column = 1;

            obj.searchButton = uibutton(obj.nameLayout,...
                "Text", "", "Icon", obj.getIcon("search"),...
                "Tag", "DropDown", "Visible", "off",...
                "ButtonPushedFcn", @obj.onPush_SearchNames);
            obj.searchButton.Layout.Row = 2;
            obj.searchButton.Layout.Column = 2;

            % INPUT THREE -------------------------------------------------
            obj.valueLayout = uigridlayout(obj.gridLayout, [2 2], gridSpecs{:});
            obj.valueLayout.Layout.Row = 1;
            obj.valueLayout.Layout.Column = 3;

            obj.valueLabel = uilabel(obj.valueLayout,... 
                "Text", " ", labelSpecs{:});
            obj.valueLabel.Layout.Row = 1;
            obj.valueLabel.Layout.Column = [1 2];

            obj.valueEditfield = uieditfield(obj.valueLayout,...
                "Value", "", "Visible", "off",...
                "ValueChangedFcn", @obj.onEdit_Value);
            obj.valueEditfield.Layout.Column = [1 2];
            obj.valueEditfield.Layout.Row = 2;

            obj.subfilterButton = uibutton(obj.valueLayout,...
                "Text", "Add subfilter", "Visible", "off",...
                "Icon", obj.getIcon('tree'),...
                "ButtonPushedFcn", @obj.onPush_AddSubfilter);
            obj.subfilterButton.Layout.Column = [1 2];
            obj.subfilterButton.Layout.Row = 2;

            % Make a few modifications if this is part of a subfilter
            if obj.isSubfilter
                obj.filterLabel.Text = "Subfilter Type";
                obj.filterDropdown.Items = setdiff(obj.filterDropdown.Items,...
                    [FilterTypes.LINK, FilterTypes.PARENT, FilterTypes.CHILD]);
            end
        end

        function close(obj)
            delete(obj.gridLayout);
        end
    end 

    methods (Access = private)
        function onSelected_FilterDropdown(obj, src, evt)
            if strcmp(evt.Value, evt.PreviousValue)
                return
            end
            obj.filterType = aod.api.FilterTypes.(upper(src.Value));
            obj.changeFilterType();
            obj.onChange_Anything();
        end

        function onPush_AddSubfilter(obj, ~, ~)
            obj.publish("AddSubfilter", obj);
        end

        function onSelect_Name(obj, ~, ~)
            obj.nameProvided = true;
            obj.onChange_Anything();
        end

        function onEdit_Name(obj, src, ~)
            if isempty(src.Value) || src.Value == ""
                obj.nameProvided = false;
            else
                obj.nameProvided = true;
            end
            obj.onChange_Anything();
        end

        function onEdit_Value(obj, src, ~)
            if isempty(src.Value) || src.Value == ""
                obj.valueProvided = false;
            else
                obj.valueProvided = true;
            end
            obj.onChange_Anything();
        end

        function onPush_SearchNames(obj, src, ~)
            if src.Tag == "DropDown"
                obj.publish("SearchRequest", obj.Parent,...
                    "ListBox", obj.nameDropdown);
                obj.showNameDropdown();
                set(src, "Tag", "EditField");
            else
                obj.showNameEditfield();
                set(src, "Tag", "DropDown");
            end
        end

        function onChange_Anything(obj)
            if obj.isSubfilter
                evtType = "ChangedSubfilterInput";
            else
                evtType = "ChangedFilterInput";
            end
            obj.publish(evtType, obj,...
                "Ready", obj.isReady);
        end
    end
end