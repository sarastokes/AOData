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

            obj.setHandler(aod.app.EventHandler(obj));
        end
    end

    % Dependent set/get methods
    methods 
        function value = get.numFilters(obj)
            if isempty(obj.Filters)
                value = 0;
            else
                value = numel(obj.Filters);
            end
        end
    end

    methods (Access = private)
        function filterID = addFilter(obj)
            filterID = obj.numFilters + 1;
            newFilter = aod.app.query.FilterBox(obj, obj.filterLayout, filterID);
            obj.Filters = [obj.Filters; newFilter];
            obj.filterLayout.RowHeight = ...
                repmat("fit", [1 obj.numFilters]);
        end
    end

    % Callback methods
    methods (Access = private)
        function onPush_AddNewFilter(obj, ~, ~)
            obj.addFilter();
        end

        function onPush_ClearFilters(obj, ~, ~)
            obj.publish("ClearFilters", obj);
        end
    end

    % aod.app.Component methods (public)
    methods
        function update(obj, evt)
            switch evt.EventType
                case "ClearFilters"
                    if strcmp(evt.EventType, "ClearFilters")
                        for i = numel(obj.Filters):-1:1
                            %delete(obj.Filters(i).gridLayout);
                            obj.Filters(i).close();
                        end
                        obj.Filters = [];
                    end
                    return
                case "PullFilter"
                    % Update the remaining filter's ID numbers
                    if numel(obj.Filters) > evt.Data.ID 
                        for i = evt.Data.ID+1:numel(obj.Filters)
                            obj.Filters(i).setFilterID(i-1);
                        end
                    end
                    % Remove the target filter
                    obj.Filters(evt.Data.ID).close();
                    delete(obj.Filters(evt.Data.ID));
                    obj.Filters(evt.Data.ID) = [];
                    % Update row heights
                    if isempty(obj.Filters)
                        obj.filterLayout.RowHeight = {"fit"};
                    else
                        obj.filterLayout.RowHeight = ...
                            repmat("fit", [1 obj.numFilters]);
                    end
                case {"PushFilter", "CheckFilter", "EditFilter"}
                    obj.Filters(evt.Data.ID).update(evt);
            end
        end
    end

    % aod.app.Component methods (protected)
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
    end
end 