classdef SearchPathView < aod.app.UIView

    events
        AddSearchPath
        RemoveSearchPath
        Save
        Cancel
    end

    properties
        searchPathListbox
    end

    methods
        function obj = SearchPathView()
            obj = obj@aod.app.UIView();
        end
    end

    methods
        function idx = getSelectedSearchPath(obj)
            idx = cellfun(@(x) isequal(x, obj.searchPathListbox.Value),...
                obj.searchPathListbox.Items);
        end

        function paths = getSearchPaths(obj)
            paths = get(obj.searchPathListbox, 'Items');
        end

        function addSearchPath(obj, path)
            s = obj.getSearchPaths();
            s = [s; {path}];
            set(obj.searchPathListbox, 'Items', s);
        end

        function removeSearchPath(obj, idx)
            s = obj.getSearchPaths();
            s(idx) = [];
            set(obj.searchPathListbox, 'Items', s);
        end

        function clearSearchPaths(obj)
            set(obj.searchPathListbox, 'Items', {});
        end
    end

    methods 
        function obj = createUi(obj)
            g = uigridlayout(obj.figureHandle, [3 2],...
                'RowHeight', {30, '1x', 30});
            
            h = uibutton(g, 'Text', 'Add Path',...
                'ButtonPushedFcn', @(h,d)notify(obj, 'AddSearchPath'));
            h.Layout.Row = 1; h.Layout.Column = 1;
            h = uibutton(g, 'Text', 'Remove',...
                'ButtonPushedFcn', @(h,d)notify(obj, 'RemoveSearchPath'));
            h.Layout.Row = 1; h.Layout.Column = 2;

            obj.searchPathListbox = uilistbox(g,"Items", {});
            obj.searchPathListbox.Layout.Row = 2;
            obj.searchPathListbox.Layout.Column = [1 2];

            h = uibutton(g, 'Text', 'Save',...
                'ButtonPushedFcn', @(h,d)notify(obj, 'Save'));
            h.Layout.Row = 3; h.Layout.Column = 1;
            h = uibutton(g, 'Text', 'Cancel',...
                'ButtonPushedFcn', @(h,d)notify(obj, 'Cancel'));
            h.Layout.Row = 3; h.Layout.Column = 2;
        end
    end
end
