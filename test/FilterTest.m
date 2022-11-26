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
        EXPT 
    end

    methods (TestClassSetup)
        function methodSetup(testCase)
            % Creates an experiment, writes to HDF5 and reads back in
            fileName = fullfile(getpref('AOData', 'BasePackage'), ...
                'test', 'ToyExperiment.h5');
            if ~exist(fileName, 'file')
                ToyExperiment(true);
            end
            testCase.EXPT = loadExperiment(fileName);
        end
    end

    methods (Test)
        function testLinkFilter(testCase)
            fObj = aod.api.LinkFilter(testCase.EXPT.hdfName, 'Parent');
            % Only Experiment does not have a parent
            testCase.verifyEqual(numel(fObj.getMatches), numel(fObj.allGroupNames) - 1);
        end

        function testEntityFilter(testCase)
            fObj = aod.api.EntityFilter(testCase.EXPT.hdfName, 'Experiment');
            % There should always be just one Experiment per file
            testCase.verifyEqual(numel(fObj.getMatches), 1);
        end

        function testParameterFilter(testCase)
            % Has parameter
            fObj = aod.api.ParameterFilter(testCase.EXPT.hdfName, 'Laboratory');
            testCase.verifyEqual(numel(fObj.getMatches), 1);
            % Specific parameter value (match)
            fObj = aod.api.ParameterFilter(testCase.EXPT.hdfName,... 
                'Laboratory', 'Primate-1P');
            testCase.verifyEqual(numel(fObj.getMatches), 1);
            % Specific parameter value (no match)
            fObj = aod.api.ParameterFilter(testCase.EXPT.hdfName,...
                'Laboratory', 'none');
            testCase.verifyEqual(numel(fObj.getMatches), 0);
        end
    end
end