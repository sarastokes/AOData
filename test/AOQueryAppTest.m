classdef AOQueryAppTest < matlab.uitest.TestCase & matlab.mock.TestCase 
    
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
            testCase.press(app.exptPanel.addButton);
            testCase.choose(app.codeTab);
            
            testCase.verifyEmpty(app.Root);
            
            % Close the figure
            close(app.figureHandle);
        end

        function OpenAppWithFile(testCase)
            app = AOQueryApp(testCase.EXPT);

            testCase.choose(app.filterTab);

            % Add a new filter
            testCase.press(app.filterPanel.addFilterButton);
            testCase.choose(app.filterPanel.Filters(1).inputBox.filterDropdown, "ENTITY");
            testCase.choose(app.filterPanel.Filters(1).inputBox.nameDropdown, "Device");
            testCase.press(app.filterPanel.Filters(1).filterControls.addButton);

            % Expand match panel
            testCase.press(app.matchPanel.expandButton);

            % Check out the code
            testCase.choose(app.codeTab);
            testCase.press(app.codePanel.copyButton);
            testCase.choose(app.matchTab);

            % Remove a filter
            testCase.press(app.filterPanel.clearFilterButton);
            testCase.choose(app.codeTab);
            testCase.choose(app.matchTab);

            % Add filter with subfilters
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