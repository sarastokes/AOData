classdef QueryView < aod.app.UIView 
% QUERYVIEW
%
% Parent:
%   aod.app.UIView
%
% Constructor:
%   obj = QueryView()
%
% See also:
%   QueryPresenter
% -------------------------------------------------------------------------

    events
        GroupsChanged
        GroupSelected

        FilterAdded
        FilterRemoved
        FilterTypeSelected
        ClassFilterChosen
        EntityFilterChosen

        ParameterNameSet
        ParameterValueSet

        ReturnTypeSelected

        QueryReset
    end

    properties 
        filterGrid
        searchGrid 

        attTable
        groupText
        groupNameLabel
        groupNameListbox
    end

    properties (Hidden, Constant)
        GH = 30; 
        ICON_DIR = [fileparts(fileparts(mfilename('fullpath'))), filesep,...
            '+icons', filesep];
    end


    methods
        function obj = QueryView()
            obj = obj@aod.app.UIView();
        end
    end

    methods
        function setGroupNames(obj, groupNames)
            obj.groupNameListbox.Items = groupNames;
            notify(obj, 'GroupsChanged');  %% TODO circuitous
        end

        function setGroupCount(obj, N, totalN)
            obj.groupNameLabel.Text = sprintf('%u of %u groups', ...
                N, totalN);
        end

        function resetGroupView(obj)
            obj.attTable.reset();
            obj.groupText.Value = "";
        end

        function displayEntity(obj, entity)
            attNames = sort(entity.attNames)';
            if ~isempty(entity.dsetNames)
                dsetNames = sort(entity.dsetNames)';
            else
                dsetNames = " ";
            end
            txt = ["ATTRIBUTES"; attNames; ""; "DATASETS:"; dsetNames];
            set(obj.groupText, 'Value', txt);
        end

        function displayAttributes(obj, entity)
            info = h5info(entity.hdfName, entity.hdfPath);
            obj.attTable.setData(info.Attributes);
        end
    end

    methods
        function value = getFilterCount(obj)
            value = getGridSize(obj.filterGrid, 1);
        end

        function value = getSearchCount(obj)
            value = getGridSize(obj.searchGrid, 1);
        end
    end

    methods 
        function createUi(obj)
            g = uigridlayout(obj.figureHandle, [1 3],...
                'ColumnWidth', ["1.2x", "1.4x", "1x"]);
            figPos(obj.figureHandle, 2, 1);

            g1 = uigridlayout(g, [2, 1],... 
                "RowHeight", ["1x","1x"]);
            g2 = uigridlayout(g, [3, 1], 'RowHeight', ["fit", "1x", "fit"]);
            g3 = uigridlayout(g, [3, 1],... 
                "RowHeight", {"fit", "1x", 30, "1x"}, "RowSpacing", 3);
            
            % Column 1
            obj.filterGrid = uigridlayout(g1, [6, 4],... 
                "RowHeight", {20,obj.GH,obj.GH,obj.GH,obj.GH,obj.GH},...
                "ColumnWidth", ["fit", "1x","1x","1x"]);
            obj.filterGrid.Layout.Row = 1;
            obj.filterGrid.Layout.Column = 1;
            h = uilabel(obj.filterGrid, "Text", "Filters:",...
                "FontWeight", "bold", "VerticalAlignment", "bottom",...
                "FontSize", 16);
            h.Layout.Row = 1; h.Layout.Column = 2;

            obj.searchGrid = uigridlayout(g1, [6,3],... 
                "RowHeight", {20,obj.GH,obj.GH,obj.GH,obj.GH,obj.GH},...
                "ColumnWidth", ["fit", "1x", "1x", "1x"]);
            obj.searchGrid.Layout.Row = 2;
            obj.searchGrid.Layout.Column = 1;
            h = uilabel(obj.searchGrid, "Text", "Searches:",...
                "FontWeight", "bold", "VerticalAlignment", "bottom",...
                "FontSize", 16);
            h.Layout.Row = 1; h.Layout.Column = 2;

            % Column 2
            uilabel(g2, "Text", "Entity Groups:",...
                "FontWeight", "bold", "VerticalAlignment", "bottom");
            obj.groupNameListbox = uilistbox(g2, "Items", {},...
                'ValueChangedFcn', @(h,d)notify(obj, 'GroupSelected', appbox.EventData(d)));
            obj.groupNameLabel = uilabel(g2);

            % Column 3
            h = uilabel(g3, "Text", "Datasets:",...
                "FontWeight", "bold", "VerticalAlignment", "bottom");
            h.Layout.Row = 1; h.Layout.Column = 1;
            obj.groupText = uitextarea(g3);
            obj.groupText.Layout.Row = 2; obj.groupText.Layout.Column = 1;
            h = uilabel(g3, "Text", "Attributes:",... 
                "FontWeight", "bold", "VerticalAlignment", "bottom");
            h.Layout.Row = 3; h.Layout.Column = 1;
            obj.attTable = aod.app.AttributeTable(g3, ...
                "FontSize", 12, "ColumnName", ["Name", "Value"]);
            obj.attTable.setLayout(4, 1);
        end

        function createDropdown(obj, parent, rc, items, eventName, varargin)
            h = uidropdown(parent, "Items", items,...
                "ValueChangedFcn", @(h,d)notify(obj, eventName, appbox.EventData(d)),... 
                "Tag", sprintf("%u_%u", rc(1), rc(2)), varargin{:});
            h.Layout.Row = rc(1);
            h.Layout.Column = rc(2);
        end

        function createEditField(obj, parent, rc, eventName, varargin)
            h = uieditfield(parent, ...
                'ValueChangedFcn', @(h,d) notify(obj, eventName, appbox.EventData(d)),... 
                "Tag", sprintf("%u_%u", rc(1), rc(2)), varargin{:});
            h.Layout.Row = rc(1);
            h.Layout.Column = rc(2);
        end

        function removeFilterButton(obj, parent, rc, varargin)
            h = uibutton(parent, "Icon", [obj.ICON_DIR, 'minus.png'],...
                "ButtonPushedFcn", @(h,d) notify(obj, 'FilterRemoved', appbox.EventData(d)),...
                "Text", "", "IconAlignment", "center", varargin{:});
            h.Layout.Row = rc(1); h.Layout.Column = rc(2);
        end

        function addFilterButton(obj, parent, rc, varargin)
            h = uibutton(parent, "Icon", [obj.ICON_DIR, 'plus.png'],...
                "ButtonPushedFcn", @(h,d) notify(obj, 'FilterAdded', appbox.EventData(d)),...
                "Text", "", "IconAlignment", "center", varargin{:});
            h.Layout.Row = rc(1); h.Layout.Column = rc(2);
        end

    end
end 