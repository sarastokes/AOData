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
        QM
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
            testCase.QM = aod.api.QueryManager(fileName);
        end
    end

    methods (Test)
        % function testLinkFilter(testCase)
        %     fObj = aod.api.LinkFilter(testCase.EXPT.hdfName, 'Parent');
        %     % Only Experiment does not have a parent
        %     testCase.verifyEqual(numel(fObj.getMatches), numel(fObj.allGroupNames) - 1);
        % end

        function testEntityFilter(testCase)
            % Clear filters in case prior method errored
            testCase.QM.clearFilters();

            EF = aod.api.EntityFilter(testCase.QM, 'Experiment');
            testCase.QM.addFilter(EF);
            [matches, idx] = testCase.QM.filter();
            % There should always be just one Experiment per file
            testCase.verifyEqual(numel(idx), 1);
            testCase.verifyEqual(height(matches), 1);
            testCase.QM.clearFilters();
        end

        function ParameterFilter(testCase)
            % Clear filters in case prior method errored
            testCase.QM.clearFilters();

            % Has parameter
            PF1 = aod.api.ParameterFilter(testCase.QM, 'Laboratory');
            idx = PF1.apply();
            testCase.verifyEqual(nnz(idx), 1);

            % Has parameter, no match
            PF4 = aod.api.ParameterFilter(testCase.QM, 'BadParam');
            testCase.verifyWarning(...
                @() PF4.apply(), "apply:NoMatches");

            % Specific parameter value (match)
            PF2 = aod.api.ParameterFilter(testCase.QM,... 
                'Laboratory', "Primate-1P");
            idx = PF2.apply();
            testCase.verifyEqual(nnz(idx), 1);

            % Specific parameter value (no match)
            PF3 = aod.api.ParameterFilter(testCase.QM,...
                'Laboratory', "none");
            testCase.verifyWarning(@() PF3.apply(), "apply:NoMatches");
            testCase.QM.addFilter(PF3);
            warning('off', 'apply:NoMatches');
            [matches, idx] = testCase.QM.filter();
            warning('on', 'apply:NoMatches');
            testCase.verifyEmpty(matches);
            testCase.verifyEqual(nnz(idx), 0);
            testCase.QM.clearFilters();
        end
    end
end