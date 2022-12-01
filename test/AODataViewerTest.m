classdef AODataViewerTest < matlab.unittest.TestCase

    properties 
        EXPT
        APP
    end

    methods (TestClassSetup)
        function openApp(testCase)
            fName = fullfile(fileparts(mfilename("fullpath")), 'test_data', 'test.h5');
            testCase.EXPT = loadExperiment(fName);
            testCase.APP = aod.app.presenters.ExperimentPresenter(testCase.EXPT);
            drawnow;
        end
    end

    methods (Test)
        function showApp(testCase)
            testCase.APP.show();
        end
    end
end