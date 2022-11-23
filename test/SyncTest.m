classdef SyncTest < matlab.unittest.TestCase 

    properties
        Experiment 
    end

    methods (TestClassSetup)
        function methodSetup(testCase)
            testCase.Experiment = ToyExperiment(false);
        end
    end

    methods (Test)
        % TODO: UUID check
        function testGroupNameSimilarityCheck(testCase)
            cal1 = aod.core.Calibration('SameName', getDateYMD());
            cal2 = aod.core.Calibration('SameName', getDateYMD());
            testCase.Experiment.add(cal1);
            testCase.verifyWarning(@() testCase.Experiment.add(cal2), ...
                "Entity:DuplicateGroupName");
        end

        function testLinkedEntitySync(testCase)
            cal = aod.core.Calibration('test1', '20220902');
            cal.setTarget(aod.core.System('externalSource'));
            testCase.verifyWarning(@() testCase.Experiment.add(cal), ...
                "Entity:SyncWarning");
            
            cal = aod.core.Calibration('test2', '20220902');
            cal.setTarget(testCase.Experiment.Systems(1));
            testCase.verifyWarningFree(@() testCase.Experiment.add(cal));
        end
    end
end 