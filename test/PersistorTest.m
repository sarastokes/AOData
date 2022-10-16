classdef PersistorTest < matlab.unittest.TestCase 

properties
    Experiment 
end

methods (TestClassSetup)
    function methodSetup(testCase)
        testCase.Experiment = ToyExperiment(true);
    end
end

methods (Test)
    function testParamSet(testCase)
        % Ensure system attributes aren't editable
        testCase.verifyWarning(@() testCase.Experiment.setParam('Class', 'TestValue'),...
            "setParam:SystemAttribute");
        
        % Add a new parameter
        testCase.verifyWarningFree(@() testCase.Experiment.setParam('TestParam', 'TestValue'));
        info = h5info('test.h5');
        testCase.verifyTrue(ismember("TestParam", string({info.Groups(1).Attributes})));

        % Remove a new parameter
        testCase.Experiment.removeParam('TestParam');
        info = h5info('test.h5');
        testCase.verifyTrue(~ismember("TestParam", string({info.Groups(1).Attributes})));
    end
end 