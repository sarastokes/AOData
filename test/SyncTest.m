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
        function testCalibrationSync(testCase)
            cal = aod.core.Calibration('test1', '20220902');
            cal.setTarget(aod.core.System('externalSource'));
            testCase.verifyWarning(@() testCase.Experiment.add(cal), "Entity:SyncWarning");
            
            cal = aod.core.Calibration('test2', '20220902');
            cal.setTarget(testCase.Experiment.Systems(1));
            testCase.verifyWarningFree(@() testCase.Experiment.add(cal));
        end

        function testEpochSync(testCase)
            ep1 = aod.core.Epoch(1);
            ep1.setSource(testCase.Experiment.Sources(1).Sources);
            ep1.setSystem(testCase.Experiment.Systems(1));

            ep2 = aod.core.Epoch(1);
            
        end
    end
end 