classdef CoreClassInstantiationTest < matlab.unittest.TestCase 

    properties
        Experiment 
    end

    methods (TestClassSetup)
        function methodSetup(testCase)
            testCase.Experiment = aod.core.Experiment(...
                '851_20220823', cd, '20220823',...
                'Administrator', 'Sara Patterson', 'System', '1P Primate');
        end
    end

    methods (Test)
        function testCalibration(testCase)
            obj = aod.core.Calibration('PowerMeasurement', '20220823');
            testCase.Experiment.addCalibration(obj);
        end

        function testSystem(testCase)
            obj = aod.core.System('SpectralPhysiology');
            testCase.Experiment.addSystem(obj);
            
            obj.addChannel(aod.core.Channel('MustangImaging'));
            obj.Channels(1).addDevice(aod.core.Device('PMT',...
                'Manufacturer', 'A', 'Model', 'B'));
        end

        function testSource(testCase)
            source = aod.core.Source('Subject');
            source.addSource(aod.core.Source('Eye'));
            testCase.Experiment.addSource(source);
        end

        function testResponse(testCase)
            resp = aod.core.Response('MyResponse');
            resp.setTiming(1:4);
        end

        function testDataset(testCase)
            dset = aod.core.Dataset('MyDataset');
        end

        function testStimulus(testCase)
            stim = aod.core.Stimulus('MyStimulus');
        end

        function testAnalysis(testCase)
            obj = aod.core.Analysis('MyAnalysis', '20220825');
            testCase.Experiment.addAnalysis(obj);
        end

    end
end 