classdef SearchPathPresenter < appbox.Presenter
% SEARCHPATHPRESENTER
%
% Description:
%   User interface for setting AOData class search paths
%
% Parent:
%   appbox.Presenter
%
% Constructor:
%   obj = SearchPathPresenter()
%   obj = SearchPathPresenter(view)
%
% See also:
%   symphonyui.presenters.OptionsPresenter
% -------------------------------------------------------------------------
    properties (Access = private)
        isChanged
    end

    methods
        function obj = SearchPathPresenter(view)
            if nargin < 1
                view = aod.app.views.SearchPathView();
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
            obj.populateSearchPaths();
        end

        function bind(obj)
            bind@appbox.Presenter(obj);

            v = obj.view;
            obj.addListener(v, 'KeyPress', @obj.onViewKeyPress);
            obj.addListener(v, 'AddSearchPath', @obj.onViewSelectedAddSearchPath);
            obj.addListener(v, 'RemoveSearchPath', @obj.onViewSelectedRemoveSearchPath);
            obj.addListener(v, 'Save', @obj.onViewSelectedSave);
            obj.addListener(v, 'Cancel', @obj.onViewSelectedCancel);
        end
    end

    methods (Access = private)
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
            dirs = strsplit(path, ';');
            for i = 1:numel(dirs)
                obj.view.addSearchPath(dirs{i});
            end
        end
    end

    % Callback methods
    methods (Access = private)
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

        function onViewSelectedRemoveSearchPath(obj, ~, ~)
            index = obj.view.getSelectedSearchPath();
            if isempty(index)
                return;
            end
            obj.view.removeSearchPath(index);
            obj.isChanged = true;
        end

        function onViewSelectedSave(obj, ~, ~)
            if ~obj.isChanged
                return
            end

            try
                paths = obj.view.getSearchPaths();
                if isempty(paths)
                    setPref('AOData', 'SearchPaths', {});
                else
                    pathList = '';
                    for i = 1:numel(paths)
                        pathList = [pathList, paths{i}]; %#ok<AGROW> 
                        if i < numel(paths)
                            pathList = [pathList, ';']; %#ok<AGROW> 
                        end
                    end
                    setpref('AOData', 'SearchPaths', pathList);
                end
                disp('Saved search paths')
            catch ME 
                obj.view.showError(ME.message);
                return
            end
        end

        function onViewSelectedCancel(obj, ~, ~)
            disp('Received')
            obj.stop();
        end

        function onViewKeyPress(obj, ~, event)
            switch event.data.Key
                case 'return'
                    obj.onViewSelectedSave();
                case 'escape'
                    obj.onViewSelectedCancel();
            end
        end
    end
end 