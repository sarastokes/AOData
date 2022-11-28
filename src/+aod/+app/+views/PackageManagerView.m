classdef PackageManagerView < aod.app.UIView
% SEARCHPATHVIEW
%
% Parent:
%   aod.app.UIView
%
% See also:
%   aod.app.presenters.PackageManagerPresenter, PackageManagerApp
% -------------------------------------------------------------------------

    events
        AddSearchPath
        RemoveSearchPath
        AddGitRepo
        RemoveGitRepo
        UpdateBasePackage
        SaveGitRepos
        SaveSearchPaths
        Cancel
    end

    properties
        searchPathListbox
        gitRepoListbox
        basePackageText
    end

    methods
        function obj = PackageManagerView()
            obj = obj@aod.app.UIView();
        end
    end

    methods
        function paths = getSearchPaths(obj)
            paths = get(obj.searchPathListbox, 'Items');
            paths = string(paths);
        end

        function paths = getGitRepos(obj)
            paths = get(obj.gitRepoListbox, "Items");
            paths = string(paths);
        end

        function path = getBasePackage(obj)
            path = string(obj.basePackageText.Text);
        end

        function idx = getSelectedGitRepo(obj)
            idx = cellfun(@(x) isequal(x, obj.gitRepoListbox.Value),...
                obj.gitRepoListbox.Items);
        end

        function idx = getSelectedSearchPath(obj)
            idx = cellfun(@(x) isequal(x, obj.searchPathListbox.Value),...
                obj.searchPathListbox.Items);
        end

        function addSearchPath(obj, path)
            s = obj.getSearchPaths();
            s = [s, string(path)];
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

        function addGitRepo(obj, path)
            s = obj.getGitRepos();
            s = [s, string(path)];
            set(obj.gitRepoListbox, "Items", s);
        end

        function removeGitRepo(obj, idx)
            s = obj.getGitRepos();
            s(idx) = [];
            set(obj.gitRepoListbox, "Items", s);
        end

        function clearGitRepos(obj)
            set(obj.gitRepoListbox, "Items", {});
        end

        function setBasePackage(obj, path)
            set(obj.basePackageText, "Text", path);
        end
    end

    methods 
        function obj = createUi(obj)
            g = uigridlayout(obj.figureHandle, [1 1]);
            tabGroup = uitabgroup(g);

            basePackageTab = uitab(tabGroup, 'Title', 'BasePackage');
            searchPathTab = uitab(tabGroup, 'Title', 'Search Paths');
            gitRepoTab = uitab(tabGroup, 'Title', 'Git Repos');

            g = uigridlayout(basePackageTab, [3 1],...
                'RowHeight', {45, 30, 45});

            h = uilabel(g, "Text", "The location of AOData folder:",...
                "FontWeight", "bold");
            h.Layout.Row = 1; h.Layout.Column = 1;

            obj.basePackageText = uilabel(g, "Text", "",...
                "BackgroundColor", "w");
            obj.basePackageText.Layout.Row = 2; 
            obj.basePackageText.Layout.Column = 1;
            
            h = uibutton(g, 'Text', 'Update',...
                'ButtonPushedFcn', @(h,d)notify(obj, 'UpdateBasePackage'));
            h.Layout.Row = 3; h.Layout.Column = 1;

            % Search path tab
            g = uigridlayout(searchPathTab, [4 2],...
                'RowHeight', {30, 30, '1x', 30});
            
            h = uilabel(g, "Text", "The folders containing packages (folders starting with +)",...
                "FontWeight", "bold");
            h.Layout.Row = 1; h.Layout.Column = [1 2];
            h = uibutton(g, 'Text', 'Add Path',...
                'ButtonPushedFcn', @(h,d)notify(obj, 'AddSearchPath'));
            h.Layout.Row = 2; h.Layout.Column = 1;
            h = uibutton(g, 'Text', 'Remove',...
                'ButtonPushedFcn', @(h,d)notify(obj, 'RemoveSearchPath'));
            h.Layout.Row = 2; h.Layout.Column = 2;

            obj.searchPathListbox = uilistbox(g,"Items", {});
            obj.searchPathListbox.Layout.Row = 3;
            obj.searchPathListbox.Layout.Column = [1 2];

            h = uibutton(g, 'Text', 'Save',...
                'ButtonPushedFcn', @(h,d)notify(obj, 'SaveSearchPaths'));
            h.Layout.Row = 4; h.Layout.Column = 1;
            h = uibutton(g, 'Text', 'Cancel',...
                'ButtonPushedFcn', @(h,d)notify(obj, 'Cancel'));
            h.Layout.Row = 4; h.Layout.Column = 2;

            % Git repo tab
            g = uigridlayout(gitRepoTab, [3 1],...
                'RowHeight', {30, 30, '1x', 30});

            h = uilabel(g, "Text", "The file paths to git repositories used:",...
                "FontWeight", "bold");
            h.Layout.Row = 1; h.Layout.Column = 1;
            h = uibutton(g, 'Text', 'Add',...
                'ButtonPushedFcn', @(h,d)notify(obj, 'AddGitRepo'));
            h.Layout.Row = 2; h.Layout.Column = 1;
            h = uibutton(g, 'Text', 'Remove',...
                'ButtonPushedFcn', @(h,d)notify(obj, 'RemoveGitRepo'));
            h.Layout.Row = 2; h.Layout.Column = 2;
            
            obj.gitRepoListbox = uilistbox(g, "Items", {});
            obj.gitRepoListbox.Layout.Row = 3;
            obj.gitRepoListbox.Layout.Column = [1 2];

            h = uibutton(g, 'Text', 'Save',...
                'ButtonPushedFcn', @(h,d)notify(obj, 'SaveGitRepos'));
            h.Layout.Row = 4; h.Layout.Column = 1;
            h = uibutton(g, 'Text', 'Cancel',...
                'ButtonPushedFcn', @(h,d)notify(obj, 'Cancel'));
            h.Layout.Row = 4; h.Layout.Column = 2;
        end
    end
end
