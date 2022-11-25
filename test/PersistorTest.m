classdef PersistorTest < matlab.unittest.TestCase 
% PERSISTORTEST
%
% Description:
%   Tests modification of HDF5 files from persistent interface
%
% Parent:
%    matlab.unittest.TestCase
%
% Use:
%   result = runtests('PersistorTest.m')
%
% See also:
%   runAODataTestSuite
% -------------------------------------------------------------------------

%#ok<*NASGU> 

    properties
        EXPT 
    end

    methods (TestClassSetup)
        function methodSetup(testCase)
            % Creates an experiment, writes to HDF5 and reads back in
            ToyExperiment(true);
            fileName = fullfile(getpref('AOData', 'BasePackage'), 'test', 'ToyExperiment.h5');
            testCase.EXPT = loadExperiment(fileName);
            testCase.EXPT.setReadOnlyMode(false);
        end
    end

    methods (Test)
        function testParamRead(testCase)
            testCase.verifyEqual(...
                testCase.EXPT.getParam('Administrator'), 'Sara Patterson');
        end

        function testCustomDisplay(testCase)
            disp(testCase.EXPT)
        end

        function testParamSet(testCase)
            import matlab.unittest.constraints.Throws

            % Ensure system attributes aren't editable
            testCase.verifyThat( ...
                @() testCase.EXPT.setParam('Class', 'TestValue'),...
                Throws("mustNotBeSystemAttribute:InvalidInput"));
            
            % Add a new parameter, ensure other attributes are editable
            testCase.EXPT.setParam('TestParam', 0);
            info = h5info('test.h5', '/Experiment');
            attributeNames = string({info.Attributes.Name});
            testCase.verifyTrue(ismember("TestParam", attributeNames));

            % Remove the new parameter
            testCase.EXPT.removeParam('TestParam');
            info = h5info('test.h5', '/Experiment');
            attributeNames = string({info.Attributes.Name});
            testCase.verifyFalse(ismember("TestParam", attributeNames));
        end
        
        function testExperimentIndexing(testCase)
            out = testCase.EXPT.Epochs(1); 
            out = testCase.EXPT.Calibrations(0);
            out = testCase.EXPT.Segmentations(0);
            out = testCase.EXPT.Systems(1);
            out = testCase.EXPT.Sources(1);
        end
    end 
end