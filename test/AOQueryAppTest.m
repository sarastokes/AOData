classdef AOQueryAppTest < matlab.uitest.TestCase & matlab.mock.TestCase 
% Test AOQueryApp framework
%
% Superclasses:
%   matlab.uitest.TestCase, matlab.mock.TestCase
%
% Syntax:
%   results = runtest('AOQueryAppTest')
%
% See also:
%   runAODataTestSuite, runAODataTest

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
        function ExperimentIO(testCase)
            app = AOQueryApp();
            testCase.verifyEqual(app.numExperiments, 0);
            testCase.verifyEmpty(app.Root);

            % Add an experiment
            testCase.press(app.exptPanel.addButton);
            testCase.verifyEqual(app.numExperiments, 1);
            testCase.verifyTrue(contains(app.matchPanel.entityLabel.Text,...
                "Total entities (28)"));
            testCase.choose(app.codeTab);
            testCase.choose(app.matchTab);

            % Remove the experiment
            testCase.choose(app.exptPanel.exptListbox, testCase.FILE);
            testCase.press(app.exptPanel.removeButton);
            testCase.verifyEqual(app.numExperiments, 0);
            
            close(app.figureHandle);
        end

        function FilterIO(testCase)
            app = AOQueryApp(testCase.EXPT);
            testCase.verifyEqual(app.numFilters, 0);

            % Add a new filter
            testCase.choose(app.filterTab);
            testCase.press(app.filterPanel.addFilterButton);
            testCase.choose(app.filterPanel.Filters(1).inputBox.filterDropdown, "ENTITY");
            testCase.choose(app.filterPanel.Filters(1).inputBox.nameDropdown, "Device");
            testCase.press(app.filterPanel.Filters(1).filterControls.addButton);
            testCase.verifyEqual(app.numFilters, 1);

            % Add a second new filter
            testCase.press(app.filterPanel.addFilterButton);
            testCase.choose(app.filterPanel.Filters(2).inputBox.filterDropdown, "NAME");
            testCase.type(app.filterPanel.Filters(2).inputBox.nameEditfield, ...
                "@(x) contains(x, 'Pinhole'");
            testCase.choose(app.filterTab);  % So typing is registered as complete
            testCase.press(app.filterPanel.Filters(2).filterControls.addButton);
            testCase.verifyEqual(app.numFilters, 2);

            % Edit the second filter
            testCase.press(app.filterPanel.Filters(2).filterControls.editButton);
            testCase.choose(app.filterPanel.Filters(2).inputBox.filterDropdown, "ATTRIBUTE");
            testCase.type(app.filterPanel.Filters(2).inputBox.nameEditfield, "Pinhole");
            testCase.type(app.filterPanel.Filters(2).inputBox.valueEditfield, '20');
            testCase.choose(app.filterTab);  % So typing is registered as complete
            testCase.press(app.filterPanel.Filters(2).filterControls.addButton);
            testCase.verifyEqual(app.numFilters, 2);
            

            % Expand match panel
            testCase.verifyFalse(app.matchPanel.isExpanded);
            testCase.press(app.matchPanel.expandButton);
            testCase.verifyTrue(app.matchPanel.isExpanded);

            % Check out the code
            testCase.choose(app.codeTab);
            testCase.verifyFalse(app.matchPanel.entityBox.isVisible());
            testCase.press(app.codePanel.copyButton);
            % Switch from script to function
            testCase.choose(app.codePanel.outputDropdown, 'function');
            testCase.verifyTrue(startsWith(app.codePanel.codeEditor.Value, 'function'));
            % Switch back
            testCase.choose(app.codePanel.outputDropdown, 'script');
            testCase.verifyFalse(startsWith(app.codePanel.codeEditor.Value, 'function'));

            % Return to the match tab
            testCase.choose(app.matchTab);
            % Select a node
            iNode = findobj(app.matchPanel.entityTree.Tree, 'Text', 'VisiblePMT');
            testCase.choose(iNode);

            % Remove all filters
            testCase.press(app.filterPanel.clearFilterButton);
            testCase.verifyEqual(app.numFilters, 0);
            testCase.verifyEmpty(app.filterPanel.Filters);

            % Confirm lazy updates
            testCase.verifyTrue(app.codePanel.isDirty);
            testCase.verifyFalse(app.codePanel.isVisible);
            testCase.choose(app.codeTab);
            testCase.verifyFalse(app.codePanel.isDirty);
            testCase.verifyTrue(app.codePanel.isVisible);

            % Close the figure
            close(app.figureHandle);
        end

        function SubfilterIO(testCase)
            app = AOQueryApp(testCase.EXPT);

            % Add filter with subfilters
            testCase.choose(app.filterTab);
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