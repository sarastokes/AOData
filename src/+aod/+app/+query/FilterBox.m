classdef FilterBox < aod.app.Component 
%
% Parent:
%   aod.app.Component
%
% Constructor:
%   obj = FilterBox(parent, canvas, ID)
%
% Children:
%   InputBox, FilterControls, SubfilterBox (optional)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    events 
        ChangeFilterType
        GrowLayout
        ShrinkLayout
    end

    properties 
        ID                  double
        filterType 
    end

    properties (Dependent)
        numSubfilters
        isReady
    end

    properties
        gridLayout          matlab.ui.container.GridLayout
        filterDropdown      matlab.ui.control.DropDown
        inputBox 
        filterControls 
        Subfilters
    end

    methods
        function obj = FilterBox(parent, canvas, ID)
            obj = obj@aod.app.Component(parent, canvas);
            obj.ID = ID;

            obj.setHandler(aod.app.query.handlers.FilterBox(obj, []));
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

        function value = get.numSubfilters(obj)
            if isempty(obj.Subfilters)
                value = 0;
            else
                value = numel(obj.Subfilters);
            end
        end
    end

    methods
        function addNewSubfilter(obj)
            subfilterID = obj.numSubfilters + 1;
            obj.gridLayout.RowHeight = repmat(obj.FILTER_HEIGHT, [1, 1 + subfilterID]);
            newSubfilter = aod.app.query.SubfilterBox(obj, obj.gridLayout, subfilterID);
            obj.Subfilters = cat(1, obj.Subfilters, newSubfilter);
            obj.Subfilters(end).gridLayout.Layout.Column = [1 3];
            obj.Subfilters(end).gridLayout.Layout.Row = subfilterID + 1;
        end

        function removeSubfilter(obj, idx)
            delete(obj.Subfilters(idx));
            obj.gridLayout.RowHeight = repmat(obj.FILTER_HEIGHT, [1, 1 + obj.numSubfilters]);
        end
    end

    methods (Access = protected)
        function value = specifyChildren(obj)
            value = [...
                obj.inputBox;...
                obj.filterControls;...
                obj.Subfilters];
        end 
        
        function createUi(obj)
            obj.gridLayout = uigridlayout(obj.Canvas, [1,3],...
                "ColumnWidth", {"1x", "2x", 70},...
                "Padding", [0 0 0 0],...
                "RowHeight", obj.FILTER_HEIGHT,...
                "BackgroundColor", rgb('light blue'));

            filterLayout = uigridlayout(obj.gridLayout, [2 1],...
                "RowHeight", {obj.TEXT_HEIGHT, "1x"}, "RowSpacing", 2,...
                "Padding", [0 5 0 0],...
                "BackgroundColor", rgb('light teal'));
            uilabel(filterLayout, "Text", "Filter Type",...
                "FontWeight", "bold", "FontSize", 12,... 
                "HorizontalAlignment", "center",...
                "VerticalAlignment", "center");
            obj.filterDropdown = uidropdown(filterLayout,...
                "Items", [""; getEnumMembers("aod.api.FilterTypes")]',...
                "ValueChangedFcn", @obj.onSelected_FilterDropdown);

            obj.inputBox = aod.app.query.InputBox(obj, obj.gridLayout);
            obj.filterControls = aod.app.query.FilterControls(obj, obj.gridLayout);
        end

        function onSelected_FilterDropdown(obj, src, evt)
            if strcmp(evt.Value, evt.PreviousValue)
                return
            end
            obj.filterType = aod.api.FilterTypes.(upper(src.Value));
            evtData = Event('ChangeFilterType', obj,... 
                'FilterType', src.Value);
            notify(obj, 'NewEvent', evtData);
        end
    end

    methods (Access = private)
        function F = buildFilter(obj)
            QM = obj.Root.QueryManager;
            if isempty(QM)
                F = [];
                return
            end
            name = obj.inputBox.getName();
            value = obj.inputBox.getValue();

            if isempty(value) || value == ""
                F = aod.api.FilterTypes.makeNewFilter(...
                    QM, {obj.filterType, name});
            else
                F = aod.api.FilterTypes.makeNewFilter(...
                    QM, {obj.filterType, name, value});
            end
        end
    end
end 