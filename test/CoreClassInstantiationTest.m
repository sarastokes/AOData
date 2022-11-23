classdef CoreClassInstantiationTest < matlab.unittest.TestCase 

    properties
        Experiment 
    end

    methods (TestClassSetup)
        function methodSetup(testCase)
            testCase.Experiment = aod.core.Experiment(...
                '851_20220823', cd, '20220823',...
                'Administrator', 'Sara Patterson',... 
                'Laboratory', '1P Primate');
        end
    end

    methods (Test)
        function testCalibration(testCase)
            obj = aod.core.Calibration('PowerMeasurement', '20220823');
            testCase.Experiment.add(obj);
        end

        function testSystem(testCase)
            obj = aod.core.System('SpectralPhysiology');
            testCase.Experiment.add(obj);
            
            obj.add(aod.core.Channel('MustangImaging'));
            obj.Channels(1).add(aod.core.Device('PMT',...
                'Manufacturer', 'A', 'Model', 'B'));
        end

        function testSource(testCase)
            source = aod.core.Source('Subject');
            source.add(aod.core.Source('Eye'));
            testCase.Experiment.add(source);
        end

        % TODO test epoch

        function testResponse(testCase) %#ok<*MANU> 
            resp = aod.core.Response('MyResponse');
            resp.setTiming(1:4);
        end

        function testDataset(testCase)
            dset = aod.core.Dataset('MyDataset'); %#ok<*NASGU> 
        end

        function testStimulus(testCase)
            stim = aod.core.Stimulus('MyStimulus');
        end

        function testAnalysis(testCase)
            obj = aod.core.Analysis('MyAnalysis', 'Date', '20220825');
            testCase.Experiment.add(obj);
        end

    end
end 