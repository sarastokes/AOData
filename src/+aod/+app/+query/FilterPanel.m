classdef FilterPanel < aod.app.Component
% Container for managing multiple AOQuery filters
%
% Superclass:
%   aod.app.Component
%
% Syntax:
%   obj = aod.app.query.FilterPanel(parent, canvas)
%
% Children:
%   FilterBox

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties
        Filters 
    end

    properties
        gridLayout              matlab.ui.container.GridLayout
        filterLayout            matlab.ui.container.GridLayout
        addFilterButton         matlab.ui.control.Button
        clearFilterButton       matlab.ui.control.Button
    end

    properties (Dependent)
        numFilters
    end

    methods
        function obj = FilterPanel(parent, canvas)
            obj = obj@aod.app.Component(parent, canvas);

            obj.setHandler(aod.app.query.handlers.FilterPanel(obj));
        end

        function value = get.numFilters(obj)
            if isempty(obj.Filters)
                value = 0;
            else
                value = numel(obj.Filters);
            end
        end
    end

    methods
        function filterID = addFilter(obj)
            filterID = obj.numFilters + 1;
            newFilter = aod.app.query.FilterBox(obj, obj.filterLayout, filterID);
            %newFilter.gridLayout.Layout.Row = filterID;
            %newFilter.gridLayout.Layout.Column = 1;
            obj.Filters = cat(1, obj.Filters, newFilter);
            obj.filterLayout.RowHeight = ... 
                repmat("fit", [1 obj.numFilters]);
        end
    end

    methods (Access = protected)
        function value = specifyChildren(obj)
            value = obj.Filters;
        end 
        
        function createUi(obj)
            obj.gridLayout = uigridlayout(obj.Canvas, [2 2],...
                "RowHeight", {"1x", 30}, "ColumnWidth", {"1x", "1x"});
            obj.filterLayout = uigridlayout(obj.gridLayout,...
                "ColumnWidth", {"1x"}, "RowHeight", {"fit"},... 
                "RowSpacing", 3, "Scrollable", "on");
            obj.filterLayout.Layout.Row = 1;
            obj.filterLayout.Layout.Column = [1 2];
            
            obj.addFilterButton = uibutton(obj.gridLayout,...
                "Text", "Add new filter",...
                "Icon", obj.getIcon('filter'),...
                "ButtonPushedFcn", @obj.onPush_AddNewFilter);
            obj.addFilterButton.Layout.Column = 1;
            obj.addFilterButton.Layout.Row = 2;

            obj.clearFilterButton = uibutton(obj.gridLayout,...
                "Text", "Clear all filters",...
                "Icon", obj.getIcon("refresh"),...
                "ButtonPushedFcn", @obj.onPush_ClearFilters);
            obj.clearFilterButton.Layout.Row = 2;
            obj.clearFilterButton.Layout.Column = 2;
        end

        function onPush_AddNewFilter(obj, ~, ~)
            obj.addFilter();
        end

        function onPush_ClearFilters(obj, ~, ~)
            for i = numel(obj.Filters):-1:1
                delete(obj.Filters(i).gridLayout);
            end
            obj.Filters = [];
        end
    end
end 