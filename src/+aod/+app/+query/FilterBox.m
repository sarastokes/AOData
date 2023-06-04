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
% Events:
%   N/A
%
% See also:
%   aod.app.query.SubfilterBox, aod.app.query.FilterPanel

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties 
        ID                  double      {mustBeInteger}
    end 

    properties (Dependent)
        isReady             logical
        isAdded             logical
        filterType
        numSubfilters       double      {mustBeInteger}
    end

    properties
        gridLayout          matlab.ui.container.GridLayout
        fillLayout          matlab.ui.container.GridLayout

        inputBox            % aod.app.query.InputBox
        filterControls      % aod.app.query.FilterControls
        Subfilters          % aod.app.query.SubfilterBoxes
    end

    methods
        function obj = FilterBox(parent, canvas, ID)
            obj = obj@aod.app.Component(parent, canvas);

            obj.ID = ID;
            obj.didGo();
            
            obj.setHandler(aod.app.query.handlers.FilterBox(obj));
        end

        function value = get.isReady(obj)
            value = obj.inputBox.isReady;
        end

        function value = get.isAdded(obj)
            value = obj.filterControls.isAdded;
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
        function setFilterID(obj, newID)
            obj.ID = newID;
        end
        
        function F = getFilter(obj)
            if ~obj.isReady
                F = [];
            else
                F = obj.buildFilter();
            end
        end
    end

    methods
        function addNewSubfilter(obj)
            subfilterID = obj.numSubfilters + 1;
            obj.gridLayout.RowHeight = ...
                repmat(obj.FILTER_HEIGHT, [1, 1 + subfilterID]);
            obj.fillLayout.RowHeight = {"fit"};
            obj.Canvas.RowHeight = {"fit"};
            newSubfilter = aod.app.query.SubfilterBox(obj,... 
                obj.gridLayout, subfilterID);
            newSubfilter.gridLayout.Layout.Column = [1 2];
            newSubfilter.gridLayout.Layout.Row = subfilterID + 1;
            obj.Subfilters = cat(1, obj.Subfilters, newSubfilter);
        end

        function removeSubfilter(obj, idx)
            close(obj.Subfilters(idx));
            obj.Subfilters(idx) = [];
            obj.gridLayout.RowHeight = repmat(obj.FILTER_HEIGHT, [1, 1 + obj.numSubfilters]);
        end

        function clearAllSubfilters(obj)
            if isempty(obj.Subfilters)
                return
            end
            for i = numel(obj.Subfilters):-1:1
                obj.removeSubfilter(i);
            end
        end
    end

    methods 
        function update(obj, evt)
            if strcmp(evt.EventType, "ChangedFilterType")
                if ~evt.Trigger.isSubfilter && ~evt.Data.FilterType.canBeNested
                    obj.clearAllSubfilters();
                end
            end  
        end
    end

    methods (Access = protected)
        function value = specifyChildren(obj)
            value = [obj.inputBox; obj.filterControls; obj.Subfilters];
        end 

        function didGo(obj)
            obj.fillLayout.Layout.Row = obj.ID; 
            obj.fillLayout.Layout.Column = 1;
        end
        
        function createUi(obj)
            obj.fillLayout = aod.app.util.uilayoutfill(obj.Canvas, 0);
            p = uipanel(obj.fillLayout);
            obj.gridLayout = uigridlayout(p, [1,2],...
                "ColumnWidth", {"1x", 60},...
                "Padding", [7 2 2 2],...
                "RowHeight", obj.FILTER_HEIGHT);

            obj.inputBox = aod.app.query.InputBox(...
                obj, obj.gridLayout, false);
            obj.filterControls = aod.app.query.FilterControls(...
                obj, obj.gridLayout);
        end

        function close(obj)
            delete(obj.fillLayout);
            close(obj.inputBox);
            close(obj.filterControls);
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
            if startsWith(name, "@")
                name = str2func(name);
            end
            value = obj.inputBox.getValue();

            if isempty(value) || value == ""
                F = aod.api.FilterTypes.makeNewFilter(...
                    QM, {obj.filterType, name});
            else % Has a value input
                eval(sprintf("inputValue = %s;", value));
                F = aod.api.FilterTypes.makeNewFilter(...
                    QM, {obj.filterType, name, inputValue});
            end
        end
    end
end 