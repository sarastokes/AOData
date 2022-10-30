classdef QueryView < aod.app.UIView 

    events
        GroupsChanged
        FilterSelected
        FilterAdded 
        FilterRemoved
        ClassFilterChosen
        EntityFilterChosen
        QueryReset
        GroupSelected
    end

    properties 
        filterGrid
        searchGrid 

        groupText
        groupNameLabel
        groupNameListbox
    end

    properties (Hidden, Constant)
        GH = 30; 
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

        function displayEntity(obj, entity)
            set(obj.groupText, 'Value',...
                {'Attributes:'; ''; 'Datasets:'});
        end
    end

    methods 
        function createUi(obj)
            g = uigridlayout(obj.figureHandle, [1 3],...
                'ColumnWidth', {"1x","1.5x","0.5x"}); %#ok<CLARRSTR> 
            figPos(obj.figureHandle, 2, 1);

            g1 = uigridlayout(g, [2, 1],... 
                "RowHeight", {"1x","1x"});
            g2 = uigridlayout(g, [2, 1], 'RowHeight', {"1x", 30});
            obj.groupText = uitextarea(g);
            
            % Column 1
            obj.filterGrid = uigridlayout(g1, [6 3],... 
                "RowHeight", {20,obj.GH,obj.GH,obj.GH,obj.GH,obj.GH},...
                "ColumnWidth", {"1x","1x","1x"});
            obj.filterGrid.Layout.Row = 1;
            obj.filterGrid.Layout.Column = 1;
            h = uilabel(obj.filterGrid, "Text", "Filters:",...
                "FontWeight", "bold");
            h.Layout.Row = 1; h.Layout.Column = 1;

            obj.searchGrid = uigridlayout(g1, [6,3],... 
                "RowHeight", {20,obj.GH,obj.GH,obj.GH,obj.GH,obj.GH});
            obj.searchGrid.Layout.Row = 2;
            obj.searchGrid.Layout.Column = 1;
            h = uilabel(obj.searchGrid, "Text", "Searches:",...
                "FontWeight", "bold");
            h.Layout.Row = 1; h.Layout.Column = 1;

            % Column 2
            obj.groupNameListbox = uilistbox(g2, "Items", {},...
                'ValueChangedFcn', @(h,d)notify(obj, 'GroupSelected', appbox.EventData(d)));
            obj.groupNameLabel = uilabel(g2);
        end

        function createDropdown(obj, parent, rc, items, eventName, varargin)
            h = uidropdown(parent, "Items", items,...
                "ValueChangedFcn", @(h,d)notify(obj, eventName, appbox.EventData(d)),... 
                varargin{:});
            h.Layout.Row = rc(1);
            h.Layout.Column = rc(2);
        end

        function createEditField(obj, parent, rc, varargin)
            h = uieditfield(parent, ...
                'ValueChangedFcn', @(h,d) notify(obj, 'FilterEdited', appbox.EventData(d)),... 
                varargin{:});
            h.Layout.Row = rc(1);
            h.Layout.Column = rc(2);
        end

        %function addFilterRow(obj, parent, rowID)
        %    h = uidropdown(parent, "Items", obj.FILTER_TYPES,...
        %        "ValueChangedFcn", @(h,d)notify(obj, 'FilterSelected', appbox.EventData(d)));
        %    h.Layout.Row = rowID; h.Layout.Column = 1;
        %end
    end
end 