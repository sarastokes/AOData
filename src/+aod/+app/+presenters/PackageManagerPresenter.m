classdef PackageManagerPresenter < appbox.Presenter
% PackageManagerPRESENTER
%
% Description:
%   User interface for setting up AOData's search paths and git repos
%
% Parent:
%   appbox.Presenter
%
% Constructor:
%   obj = aod.app.presenters.PackageManagerPresenter()
%   obj = aod.app.presenters.PackageManagerPresenter(view)
%
% See also:
%   AODataManagerApp, aod.app.views.PackageManagerView

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (Access = private)
        isChanged
    end

    methods
        function obj = PackageManagerPresenter(view)
            if nargin < 1
                view = aod.app.views.PackageManagerView();
            end
            obj = obj@appbox.Presenter(view);
            obj.isChanged = false;
            obj.go();
        end

        function v = getView(obj)
            v = obj.view;
        end
    end

    methods (Access = protected)
        function willGo(obj)
            if ~ispref('AOData')
                initializeAOData();
            end
            obj.populateBasePackage();
            obj.populateSearchPaths();
            obj.populateGitRepos();
        end

        function bind(obj)
            bind@appbox.Presenter(obj);

            v = obj.view;
            obj.addListener(v, 'KeyPress', @obj.onViewKeyPress);
            obj.addListener(v, 'UpdateBasePackage', @obj.onViewSelectedUpdateBasePackage);
            obj.addListener(v, 'AddSearchPath', @obj.onViewSelectedAddSearchPath);
            obj.addListener(v, 'RemoveSearchPath', @obj.onViewSelectedRemoveSearchPath);
            obj.addListener(v, 'SaveSearchPaths', @obj.onViewSelectedSaveSearchPaths);
            obj.addListener(v, 'AddGitRepo', @obj.onViewSelectedAddGitRepo);
            obj.addListener(v, 'RemoveGitRepo', @obj.onViewSelectedRemoveGitRepo);
            obj.addListener(v, 'SaveGitRepos', @obj.onViewSelectedSaveGitRepos);
            obj.addListener(v, 'Cancel', @obj.onViewSelectedCancel);
        end
    end

    methods (Access = private)
        function populateBasePackage(obj)
            basePath = getpref('AOData', 'BasePackage');
            obj.view.setBasePackage(basePath);
        end

        function populateSearchPaths(obj)
            obj.view.clearSearchPaths();
            tf = ispref('AOData', 'SearchPaths');
            if ~tf
                obj.isChanged = true;
                return
            end
            path = getpref('AOData', 'SearchPaths');
            if isempty(path)
                return
            end
            path = semicolonchar2string(path);
            for i = 1:numel(path)
                obj.view.addSearchPath(path(i));
            end
        end

        function populateGitRepos(obj)
            obj.view.clearGitRepos();
            tf = ispref('AOData', 'GitRepos');
            if ~tf 
                obj.isChanged = true;
                return
            end
            path = getpref('AOData', 'GitRepos');
            if isempty(path)
                return
            end
            path = semicolonchar2string(path);
            for i = 1:numel(path)
                obj.view.addGitRepo(path(i));
            end
        end

        function hardReset(obj)
            initializeAOData(true);
            obj.populateBasePackage();
            obj.populateSearchPaths();
            obj.populateGitRepos();
        end
    end

    % Callback methods
    methods (Access = private)
        function onViewSelectedUpdateBasePackage(obj, ~, ~)
            initializeAOData();
            obj.populateBasePackage();
            obj.populateGitRepos();
        end

        function onViewSelectedAddSearchPath(obj, ~, ~)
            path = obj.view.showGetDirectory('Select Path');
            if isempty(path)
                return;
            end
            [~, name] = fileparts(path);
            if strncmp(name, '+', 1)
                obj.view.showError(['Cannot add package directories (directories starting with +) to the ' ...
                    'search path. Add the root directory containing the package instead.']);
                return;
            end
            obj.view.addSearchPath(path);
            obj.isChanged = true;
        end

        function onViewSelectedAddGitRepo(obj, ~, ~)
            path = obj.view.showGetDirectory('Select Git Repo Folder');
            if isempty(path)
                return
            end
            folderContents = arrayfun(@(x) string(x.name), dir(path));
            if ~ismember(".git", folderContents)
                obj.view.ShowError('Folder is not a git repo: no .git folder found within selected path.');
                return
            end
            obj.view.addGitRepo(path);
            obj.isChanged = true;
        end

        function onViewSelectedRemoveSearchPath(obj, ~, ~)
            index = obj.view.getSelectedSearchPath();
            if isempty(index)
                return;
            end
            obj.view.removeSearchPath(index);
            obj.isChanged = true;
        end

        function onViewSelectedRemoveGitRepo(obj, ~, ~)
            index = obj.view.getSelectedGitRepo();
            if isempty(index)
                return
            end
            obj.view.removeGitRepo(index);
            obj.isChanged = true;
        end

        function onViewSelectedSaveSearchPaths(obj, ~, ~)
            if ~obj.isChanged
                return
            end

            try
                paths = obj.view.getSearchPaths();
                if isempty(paths)
                    obj.view.showError('Search Paths must at least include AOData package!');
                    % obj.hardReset();
                    return
                else
                    paths = string(paths);
                    setpref('AOData', 'SearchPaths', string2semicolonchar(paths));
                end
                disp('Saved search paths')
            catch ME 
                obj.view.showError(ME.message);
                return
            end
        end

        function onViewSelectedSaveGitRepos(obj, ~, ~)
            if ~obj.isChanged
                return
            end

            try
                paths = obj.view.getGitRepos();
                if isempty(paths)
                    setpref('AOData', 'GitRepos', []);
                else
                    paths = string(paths);
                    setpref('AOData', 'GitRepos', string2semicolonchar(paths));
                end
                disp('Saved git repos');
            catch
                obj.view.showError(ME.message);
                return
            end
        end

        function onViewSelectedCancel(obj, ~, ~)
            obj.stop();
        end

        function onViewKeyPress(obj, ~, event)
            switch event.data.Key
                case 'escape'
                    obj.onViewSelectedCancel();
            end
        end
    end
end 