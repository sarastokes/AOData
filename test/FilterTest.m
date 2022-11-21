classdef FilterTest < matlab.unittest.TestCase
% FILTERTEST
%
% Description:
%   Tests AOQuery filters
%
% Parent:
%    matlab.unittest.TestCase
%
% Use:
%   result = runtests('FilterTest.m')
% -------------------------------------------------------------------------

    properties
        Experiment 
    end

    methods (TestClassSetup)
        function methodSetup(testCase)
            testCase.Experiment = ToyExperiment(true);
        end
    end

    methods (Test)
        function testLinkFilter(testCase)
            fObj = aod.api.LinkFilter(obj.Experiment.hdfName, 'Parent');
            % Only Experiment does not have a parent
            testCase.verifyEqual(numel(fObj.getMatches), numel(fObj.allGroupNames) - 1);
        end
    end
end