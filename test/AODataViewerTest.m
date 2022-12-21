classdef AODataViewerTest < matlab.uitest.TestCase

    properties 
        EXPT
        VIEW
        APP
    end

    methods (TestClassSetup)
        function openApp(testCase)
            fName = fullfile(fileparts(mfilename("fullpath")), 'test_data', 'test.h5');
            testCase.EXPT = loadExperiment(fName);
            testCase.APP = aod.app.presenters.ExperimentPresenter(testCase.EXPT);
            testCase.APP.show();
            testCase.VIEW = testCase.APP.getView();
            drawnow;
        end
    end

    methods (TestClassTeardown)
        function closeApp(testCase)
            testCase.VIEW.close();
        end
    end

    methods (Test)
        function SelectAndExpand(testCase)
            % Select Experiment
            h = testCase.VIEW.Tree.Children;
            testCase.choose(h);
            testCase.verifyTrue(...
                any(contains(testCase.VIEW.Attributes.Data{:,1}, 'Administrator')));
            
            % Expand Experiment
            expand(h);
            notify(testCase.VIEW, 'NodeExpanded', appbox.EventData(struct('Node', h)));

            testCase.choose(h.Children(1));
            testCase.verifyEqual(...
                string(testCase.VIEW.Attributes.Data{1,2}), "Container");
        end
    end
end