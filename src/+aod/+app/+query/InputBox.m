classdef InputBox < Component 
%
% Parent:
%   Component
%
% Children:
%   N/A

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    events 
        AddSubfilter 
        NameProvided
        SearchNames
        NameInterfaceChanged
        ValueProvided
    end

    properties (SetAccess = private)
        filterType              = aod.api.FilterTypes.UNDEFINED
        nameProvided            logical
        valueProvided           logical 
    end

    properties (Dependent)
        isReady
    end

    properties
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
        function obj = InputBox(parent, canvas)
            obj = obj@Component(parent, canvas);

            obj.setHandler(aod.app.query.handlers.InputBox(obj));

            obj.nameProvided = false;
            obj.valueProvided = false;
        end

        function value = get.isReady(obj)
            import aod.api.FilterTypes 

            if isempty(obj.filterType) || obj.filterType == FilterTypes.UNDEFINED 
                value = false;
            elseif obj.nameProvided
                value = true; 
            else
                value = false;
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

        function changeFilterType(obj, filterType)
            
            obj.reset();

            if isempty(filterType)
                obj.filterType = aod.api.FilterTypes.UNDEFINED;
                return
            end

            import aod.api.FilterTypes

            switch filterType 
                case FilterTypes.ENTITY
                    obj.setNameLabel("Entity Type");
                    obj.showOneInput();
                    obj.showNameDropdown();
                    obj.nameDropdown.Items = ... 
                        [""; getEnumMembers('aod.core.EntityTypes')]';
                    obj.searchButton.Visible = "off";
                case FilterTypes.NAME 
                    obj.setNameLabel("Entity Name");
                    obj.showNameEditfield();
                    obj.hideSearchButton();
                    obj.showOneInput();
                case FilterTypes.CLASS
                    obj.setNameLabel("Class Name")
                    obj.showNameEditfield();
                    obj.showSearchButton();
                    obj.showOneInput();
                case {FilterTypes.PARAMETER, FilterTypes.DATASET}
                    obj.setNameLabel("Name");
                    obj.hideSearchButton();
                    obj.setValueLabel("Value");
                    obj.showValueEditfield("Value");
                case FilterTypes.LINK
                    obj.setNameLabel("Link Name");
                    obj.showSubfilterButton();
                case FilterTypes.PARENT
                    obj.setNameLabel("Parent Type");
                    obj.nameDropdown.Items = ... 
                        [""; getEnumMembers('aod.api.FilterTypes')]';
                    obj.showSubfilterButton();
                case FilterTypes.CHILD
                    obj.setNameLabel("Child Type");
                    obj.nameDropdown.Items = ... 
                        [""; getEnumMembers('aod.api.FilterTypes')]';
                    obj.showSubfilterButton();
                    obj.hideSearchButton();
                case FilterTypes.UUID
                    obj.setNameLabel("UUID");
                    obj.hideSearchButton();
                    obj.showOneInput();
                case FilterTypes.PATH
                    obj.setNameLabel("HDF5 Path");
                    obj.hideSearchButton();
                    obj.showOneInput();
                otherwise
                    error('changeFilterType:UnknownFilterType',...
                        'Filter %s not recognized', char(filterType));
            end

            obj.filterType = filterType;
        end
    end

    methods
        function setNameLabel(obj, txt)
            obj.nameLabel.Text = txt;
        end
    
        function setValueLabel(obj, txt)
            obj.valueLabel.Text = txt;
        end

        function showSubfilterButton(obj)
            obj.setValueLabel("(optional)");
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
                obj.setNameLabel(lbl);
            end
            obj.nameDropdown.Visible = "off";
            obj.nameEditfield.Visible = "on";
            obj.searchButton.Icon = obj.getIcon("dropdown");
        end

        function showValueEditfield(obj, label)
            if nargin < 2
                label = "";
            end
            obj.setValueLabel(label);  % Rearrange layout
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

        function showOneInput(obj)
            obj.valueLabel.Visible = "off";
            obj.subfilterButton.Visible = "off";
            obj.valueEditfield.Visible = "off";
        end
    end

    methods (Access = protected)
        function createUi(obj)
            mainLayout = uigridlayout(obj.Canvas, [1 2],...
                "ColumnWidth", {"1x", "1x"}, "RowHeight",  {"1x"},...
                "Padding", [0 0 0 0], "ColumnSpacing", 2);

            % INPUT ONE ---------------------------------------------------
            obj.nameLayout = uigridlayout(mainLayout, [2 2],...
                "RowHeight", {obj.TEXT_HEIGHT, "1x"},...
                "ColumnWidth", {"1x", obj.BUTTON_WIDTH},...
                "RowSpacing", 2, "ColumnSpacing", 2,...
                "Padding", [0 5 0 0],...
                "BackgroundColor", rgb('mint'));
            obj.nameLayout.Layout.Column = 1;
            obj.nameLayout.Layout.Row = 1;
            obj.nameLabel = uilabel(obj.nameLayout,... 
                "Text", "", "FontWeight", "bold", "FontSize", 12,...
                "HorizontalAlignment", "center",...
                "VerticalAlignment", "center");
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
                "Text", "", "Icon", obj.getIcon("dropdown"),...
                "Visible", "off",...
                "ButtonPushedFcn", @obj.onPush_SearchNames);
            obj.searchButton.Layout.Row = 2;
            obj.searchButton.Layout.Column = 2;

            % INPUT TWO ---------------------------------------------------
            obj.valueLayout = uigridlayout(mainLayout, [2 1],...
                "RowHeight", {obj.TEXT_HEIGHT, "1x"},...
                "RowSpacing", 2,...
                "Padding", [0 5 0 0],...
                "BackgroundColor", rgb('light red'));
            obj.valueLayout.Layout.Column = 2;
            obj.valueLayout.Layout.Row = 1;

            obj.valueLabel = uilabel(obj.valueLayout,... 
                "Text", " ", "FontSize", 12, "FontWeight", "bold",...
                "HorizontalAlignment", "center",...
                "VerticalAlignment", "center");

            obj.valueEditfield = uieditfield(obj.valueLayout,...
                "Value", "", "Visible", "off",...
                "ValueChangedFcn", @obj.onEdit_Value);
            obj.valueEditfield.Layout.Row = 2;

            obj.subfilterButton = uibutton(obj.valueLayout,...
                "Text", "Add subfilter", "Visible", "off",...
                "Icon", obj.getIcon('tree'),...
                "ButtonPushedFcn", @obj.onPush_AddSubfilter);
            obj.subfilterButton.Layout.Row = 2;
        end

        function onPush_AddSubfilter(obj, src, evt)
            evtData = Event('AddSubfilter', obj);
            notify(obj, 'NewEvent', evtData);
        end

        function onSelect_Name(obj, src, evt)
            obj.nameProvided = true;
        end

        function onEdit_Name(obj, src, evt)
            if isempty(src.Value) || src.Value == ""
                obj.nameProvided = false;
            else
                obj.nameProvided = true;
            end
        end

        function onEdit_Value(obj, src, evt)
            if isempty(src.Value) || src.Value == ""
                obj.valueProvided = false;
            else
                obj.valueProvided = true;
            end
        end

        function onPush_SearchNames(obj, src, evt)
            notify(obj, 'SearchNames')
        end
    end

end