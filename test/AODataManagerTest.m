classdef AODataManagerTest < matlab.uitest.TestCase & matlab.mock.TestCase
% Test the AODataViewer framework
%
% Description:
%   Tests AODataManager UI and back-end
%
% Parent:
%   matlab.unittest.TestCase
%
% Example:
%   results = runtests('AODataManagerTest.m')
%
% See also:
%   runAODataTestSuite, AODataManagerApp
%
% Reference:
%   Buttons: "UpdateButton", 
%            "AddSearchButton", "RemoveSearchButton"
%            "SaveSearchButon", "CancelSearchButton"
%            "AddRepoButton", "RemoveRepoButton",
%            "SaveRepoButton", "CancelRepoButton",

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties 
        PREFS
        FOLDER
    end

    methods (TestClassSetup)
        function StoreAndClearPreferences(testCase)
            testCase.PREFS = getpref('AOData');
            assignin('base', 'PREFS', getpref('AOData'));
            % This will only work on my computer...
            testCase.FOLDER = fullfile(testCase.PREFS.BasePackage,...
                'lib', 'h5tools-matlab');
        end
    end

    methods (TestClassTeardown)
        function RestorePreferences(testCase)
            % Backup to ensure preferences are restored
            testCase.restorePreferences();
        end
    end

    methods
        function restorePreferences(testCase)
            f = fieldnames(testCase.PREFS);
            for i = 1:numel(f)
                setpref('AOData', f{i}, testCase.PREFS.(f{i}));
            end
        end
    end

    methods (Test)
        function DisplayAccuracy(testCase)
            app = aod.app.presenters.PackageManagerPresenter();
            view = app.getView();

            % Ensure app displays preferences correctly
            testCase.verifyEqual(testCase.PREFS.BasePackage,... 
                view.basePackageText.Text);

            numItems = numel(find(testCase.PREFS.SearchPaths == ';')) + 1;
            testCase.verifyNumElements(view.searchPathListbox.Items, numItems);
            notify(view, 'SaveSearchPaths');
            testCase.verifyEqual(getpref('AOData', 'SearchPaths'),...
                testCase.PREFS.SearchPaths);

            numItems = numel(find(testCase.PREFS.GitRepos == ';')) + 1;
            testCase.verifyNumElements(view.gitRepoListbox.Items, numItems);
            notify(view, 'SaveGitRepos');
            testCase.verifyEqual(getpref('AOData', 'GitRepos'),...
                testCase.PREFS.GitRepos);

            % Close the view (through a callback)
            notify(view, 'Cancel');
        end

        function SetSearchPaths(testCase)
            % Ensure app assigns preferences correctly
            import matlab.mock.actions.AssignOutputs
            
            [mock, behavior] = testCase.createMock(...
                ?aod.app.util.FolderChooser);
            testCase.assignOutputsWhen(withAnyInputs(behavior.chooseFolder),...
                testCase.FOLDER);
        
            view = aod.app.views.PackageManagerView(...
                'FolderChooser', mock);
            app = aod.app.presenters.PackageManagerPresenter(view);

            % Access components of UI
            fig = app.getFigure();
            tabGroup = findByTag(fig, 'TabGroup');

            % Add a search path
            tabGroup.SelectedTab = findByTag(fig, 'SearchTab');
            numItems = numel(view.searchPathListbox.Items);
            notify(view, 'AddSearchPath');
            testCase.verifyCalled(withAnyInputs(behavior.chooseFolder));
            testCase.verifyNumElements(view.searchPathListbox.Items, numItems+1);

            % Remove the search path
            testCase.choose(view.searchPathListbox,...
                view.searchPathListbox.Items{end});
            testCase.press(findByTag(fig, 'RemoveSearchButton'));
            testCase.verifyNumElements(view.searchPathListbox.Items, numItems);

            % Clear mock history
            testCase.clearMockHistory(mock);

            % Add a git repo
            tabGroup.SelectedTab = findByTag(fig, 'RepoTab');
            numItems = numel(view.gitRepoListbox.Items);
            notify(view, 'AddGitRepo');
            testCase.verifyCalled(withAnyInputs(behavior.chooseFolder));
            testCase.verifyNumElements(view.gitRepoListbox.Items, numItems+1);

            % Remove the git repo
            testCase.choose(view.gitRepoListbox,...
                view.gitRepoListbox.Items{end});
            testCase.press(findByTag(fig, 'RemoveRepoButton'));
            testCase.verifyNumElements(view.gitRepoListbox.Items, numItems);

            % Update base package (shouldn't change)
            notify(view, 'UpdateBasePackage');
            testCase.verifyEqual(testCase.PREFS.BasePackage,... 
                view.basePackageText.Text);

            % Close the view (through a callback)
            notify(view, 'Cancel');
        end
    end
end