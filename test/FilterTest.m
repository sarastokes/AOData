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

        function testEntityFilter(testCase)
            fObj = aod.api.EntityFilter(obj.Experiment.hdfName, 'Experiment');
            testCase.verifyEqual(numel(fObj.getMatches), 1);
        end

        function testParameterFilter(testCase)
            % Has parameter
            fObj = aod.api.ParameterFilter(obj.Experiment.hdfName, 'Laboratory');
            testCase.verifyEqual(numel(fObj.getMatches), 1);
            % Specific parameter value
            fObj = aod.api.ParameterFilter(obj.Experiment.hdfName,... 
                'Laboratory', 'Primate-1P');
            testCase.verifyEqual(numel(fObj.getMatches), 1);
            fObj = aod.api.ParameterFilter(obj.Experiment.hdfName,...
                'Laboratory', 'none');
            testCase.verifyEqual(numel(fObj.getMatches), 0);
        end
    end
end