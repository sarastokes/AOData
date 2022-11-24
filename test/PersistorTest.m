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
% -------------------------------------------------------------------------

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
        function testParamSet(testCase)
            % Ensure system attributes aren't editable
            testCase.verifyWarning( ...
                @() testCase.EXPT.setParam('Class', 'TestValue'),...
                "setParam:SystemAttribute");
            
            % Add a new parameter, ensure other attributes are editable
            testCase.verifyWarningFree( ...
                @() testCase.EXPT.setParam('TestParam', 'TestValue'));
            info = h5info('test.h5', '/Experiment');
            attributeNames = string({info.Attributes});
            testCase.verifyTrue(ismember("TestParam", attributeNames));

            % Remove the new parameter
            testCase.EXPT.removeParam('TestParam');
            info = h5info('test.h5', '/Experiment');
            attributeNames = string({info.Attributes});
            testCase.verifyTrue(ismember("TestParam", attributeNames));
        end 
    end 
end