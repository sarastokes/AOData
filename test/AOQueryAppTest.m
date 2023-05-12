classdef AOQueryAppTest < matlab.uitest.TestCase & matlab.mock.TestCase 
%
% Syntax:
%   results = runtest('AOQueryAppTest')
%

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties
        FILE 
        EXPT 
    end

    methods (TestClassSetup)
        function testSetup(testCase)
            testCase.FILE = fullfile(getpref('AOData', 'BasePackage'), ...
                'test', 'ToyExperiment.h5');

            if ~exist(testCase.FILE, 'file')
                ToyExperiment(true, true);
            end

            testCase.EXPT = loadExperiment(testCase.FILE);
        end
    end

    methods (Test)
        function OpenAppWithoutFile(testCase)
            app = AOQueryApp();
            testCase.verifyEqual(app.numExperiments, 0);
            testCase.press(app.exptPanel.addButton);
            testCase.verifyEqual(app.numExperiments, 1);
            testCase.verifyTrue(contains(app.matchPanel.entityLabel.Text,...
                "Total entities (28)"));
            testCase.choose(app.codeTab);
            
            testCase.verifyEmpty(app.Root);

            % Close the figure
            close(app.figureHandle);
        end

        function OpenAppWithFile(testCase)
            app = AOQueryApp(testCase.EXPT);
            testCase.verifyEqual(app.numExperiments, 1);

            testCase.choose(app.filterTab);
            testCase.verifyEqual(app.numFilters, 0);

            % Add a new filter
            testCase.press(app.filterPanel.addFilterButton);
            testCase.choose(app.filterPanel.Filters(1).inputBox.filterDropdown, "ENTITY");
            testCase.choose(app.filterPanel.Filters(1).inputBox.nameDropdown, "Device");
            testCase.press(app.filterPanel.Filters(1).filterControls.addButton);
            testCase.verifyEqual(app.numFilters, 1);

            % Expand match panel
            testCase.verifyFalse(app.matchPanel.isExpanded);
            testCase.press(app.matchPanel.expandButton);
            testCase.verifyTrue(app.matchPanel.isExpanded);

            % Check out the code
            testCase.choose(app.codeTab);
            testCase.press(app.codePanel.copyButton);
            testCase.choose(app.matchTab);

            % Remove all filters
            testCase.press(app.filterPanel.clearFilterButton);
            testCase.verifyEqual(app.numFilters, 0);
            testCase.verifyEmpty(app.filterPanel.Filters);
            testCase.verifyTrue(app.codePanel.isDirty);
            testCase.verifyFalse(app.codePanel.isVisible);

            testCase.choose(app.codeTab);
            testCase.verifyFalse(app.codePanel.isDirty);
            testCase.verifyTrue(app.codePanel.isVisible);

            % Add filter with subfilters
            testCase.choose(app.matchTab);
            testCase.press(app.filterPanel.addFilterButton);
            testCase.choose(app.filterPanel.Filters(1).inputBox.filterDropdown, "LINK");
            testCase.verifyEqual(app.filterPanel.Filters(1).numSubfilters, 0);
            testCase.press(app.filterPanel.Filters(1).inputBox.subfilterButton);
            testCase.verifyEqual(app.filterPanel.Filters(1).numSubfilters, 1);

            % Specify the subfilter
            testCase.choose(app.filterPanel.Filters(1).Subfilters(1).inputBox.filterDropdown, "CLASS");

            % Request name dropdown
            testCase.press(app.filterPanel.addFilterButton);
            testCase.choose(app.filterPanel.Filters(2).inputBox.filterDropdown, "CLASS");
            testCase.press(app.filterPanel.Filters(2).inputBox.searchButton);
            testCase.press(app.filterPanel.Filters(2).inputBox.searchButton);

            % Close the figure
            close(app.figureHandle);
        end
    end
end 