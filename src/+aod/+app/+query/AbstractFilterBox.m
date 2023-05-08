classdef AbstractFilterBox < Component 

    properties 
        ID          double  {mustBeInteger}
    end

    properties (Dependent)
        isReady
    end

    properties 
        gridLayout          matlab.ui.container.GridLayout 
        filterDropdown      matlab.ui.control.DropDown 
        filterLabel         matlab.ui.control.Label
        inputBox 
        filterControls 
    end

    methods 
        function obj = FilterBox(parent, canvas, ID)
            obj = obj@Component(parent, canvas);
            obj.ID = ID;
        end

        function setFilterID(obj, newID)
            obj.ID = newID;
        end

        function value = get.isReady(obj)
            if obj.filterDropdown.Value == "UNDEFINED"
                value = false;
            else
                value = obj.inputBox.isReady;
            end
        end
    end

    methods (Access = protected)
        function value = specifyChildren(obj)
            value = [obj.inputBox; obj.filterControls];
        end

        function createUi(obj)
            obj.gridLayout = uigridlayout(obj.Canvas, [1, 3],...
                "ColumnWidth", {"1x", "2x", 70},...
                "Padding", [0 0 0 0],...
                "RowHeight", obj.FILTER_HEIGHT,...
                "BackgroundColor", rgb('pale blue'));
            
            filterLayout = uigridlayout(obj.gridLayout, [2 1],...
                "RowHeight", {obj.TEXT_HEIGHT, "1x"},...
                "RowSpacing", 2,...
                "BackgroundColor", rgb('light teal'));
            obj.filterLabel = uilabel(filterLayout,... 
                "Text", "FilterType", ...
                "FontWeight", "bold", "FontSize", 12, ...
                "HorizontalAlignment", "center", ...
                "VerticalAlignment", "center");
            obj.filterDropdown = uidropdown(filterLayout,...
                "Items", [getEnumMembers("aod.api.FilterTypes")]',...
                "ValueChangedFcn", @obj.onSelected_FilterDropdown);

            obj.inputBox = aod.app.query.InputBox(obj, obj.gridLayout);
            obj.filterControls = aod.app.query.FilterControls(obj, obj.gridLayout);
        end

        function onSelected_FilterDropdown(obj, src, evt)

            if strcmp(evt.Value, evt.PreviousValue)
                return
            end

            obj.filterType = aod.api.FilterTypes.(upper(src.Value));
            evtData = aod.app.Event('ChangeFilterType', obj, ...
                'FilterType', src.Value);
            notify(obj, 'NewEvent', evtData);
        end
    end
end 