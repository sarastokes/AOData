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

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    events 
        AddSubfilter 
        SearchNames
    end

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

            obj.setHandler(aod.app.query.handlers.InputBox(obj));

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
            obj.searchButton.Icon = obj.getIcon("search");
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
            filterLayout = uigridlayout(mainLayout, [2 2],...
                "BackgroundColor", rgb('light teal'), gridSpecs{:});
            filterLayout.Layout.Row = 1;
            filterLayout.Layout.Column = 1;
            
            obj.filterLabel = uilabel(filterLayout,... 
                "Text", "Filter Type", labelSpecs{:});
            obj.filterLabel.Layout.Column = [1 2];

            obj.filterDropdown = uidropdown(filterLayout, ...
                "Items", getEnumMembers("aod.api.FilterTypes")', ...
                "ValueChangedFcn", @obj.onSelected_FilterDropdown);
            obj.filterDropdown.Layout.Column = [1 2];

            % INPUT TWO ---------------------------------------------------
            obj.nameLayout = uigridlayout(mainLayout, [2 2],...
                "BackgroundColor", rgb('mint'), gridSpecs{:});
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
                "Visible", "off",...
                "ButtonPushedFcn", @obj.onPush_SearchNames);
            obj.searchButton.Layout.Row = 2;
            obj.searchButton.Layout.Column = 2;

            % INPUT THREE -------------------------------------------------
            obj.valueLayout = uigridlayout(mainLayout, [2 2],...
                "BackgroundColor", rgb('light red'), gridSpecs{:});
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

        function onSelected_FilterDropdown(obj, src, evt)
            if strcmp(evt.Value, evt.PreviousValue)
                return
            end
            obj.filterType = aod.api.FilterTypes.(upper(src.Value));
            obj.changeFilterType();
            obj.onChange_Anything();
        end

        function onPush_AddSubfilter(obj, src, evt)
            evtData = aod.app.Event('AddSubfilter', obj);
            notify(obj, 'NewEvent', evtData);
        end

        function onSelect_Name(obj, src, evt)
            obj.nameProvided = true;
            obj.onChange_Anything();
        end

        function onEdit_Name(obj, src, evt)
            if isempty(src.Value) || src.Value == ""
                obj.nameProvided = false;
            else
                obj.nameProvided = true;
            end
            obj.onChange_Anything();
        end

        function onEdit_Value(obj, src, evt)
            if isempty(src.Value) || src.Value == ""
                obj.valueProvided = false;
            else
                obj.valueProvided = true;
            end
            obj.onChange_Anything();
        end

        function onPush_SearchNames(obj, src, evt)
            evtData = aod.app.Event('AddSubfilter', obj);
            notify(obj, 'SearchNames', evtData);
        end

        function onChange_Anything(obj)
            if obj.isSubfilter
                evtType = "ChangedSubfilterInput";
            else
                evtType = "ChangedFilterInput";
            end
            evtData = aod.app.Event(evtType, obj, 'Ready', obj.isReady);
            notify(obj, 'NewEvent', evtData);
        end
    end

end