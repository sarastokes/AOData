classdef FilterBox < aod.app.Component 
% Interface for a single AOQuery filter
%
% Superclass:
%   aod.app.Component
%
% Constructor:
%   obj = aod.app.query.FilterBox(parent, canvas, ID)
%
% Children:
%   InputBox, FilterControls, SubfilterBox (optional)
%
% See also:
%   aod.app.query.SubfilterBox, aod.app.query.FilterPanel

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    events 
        ChangeFilterType
        GrowLayout
        ShrinkLayout
    end

    properties 
        ID                  double
    end

    properties (Dependent)
        isReady             logical
        filterType
        numSubfilters       double      {mustBeInteger}
    end

    properties
        gridLayout          matlab.ui.container.GridLayout
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
            value = obj.inputBox.isReady;
        end

        function value = get.filterType(obj)
            value = obj.inputBox.filterType;
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
            obj.Subfilters(end).gridLayout.Layout.Column = [1 2];
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
                "ColumnWidth", {"1x", 70},...
                "Padding", [0 0 0 0],...
                "RowHeight", obj.FILTER_HEIGHT,...
                "BackgroundColor", rgb('light blue'));

            obj.inputBox = aod.app.query.InputBox(obj, obj.gridLayout, false);
            obj.filterControls = aod.app.query.FilterControls(obj, obj.gridLayout);
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