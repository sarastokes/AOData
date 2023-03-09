classdef FilterTest < matlab.unittest.TestCase
% Test AOQuery filters
%
% Description:
%   Tests AOQuery filters for identifying entities in a persisted dataset
%
% Parent:
%    matlab.unittest.TestCase
%
% Use:
%   result = runtests('FilterTest.m')

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties
        FILENAME
        EXPT 
        QM
    end

    methods (TestClassSetup)
        function methodSetup(testCase)
            % Creates an experiment, writes to HDF5 and reads back in
            testCase.FILENAME = fullfile(getpref('AOData', 'BasePackage'), ...
                'test', 'ToyExperiment.h5');
            if ~exist(testCase.FILENAME, 'file')
                ToyExperiment(true, true);
            end
            testCase.EXPT = loadExperiment(testCase.FILENAME);
            testCase.QM = aod.api.QueryManager(testCase.FILENAME);
        end
    end

    methods (Test, TestTags="QueryManager")
        function QueryManager(testCase)
            % Clear filters in case prior method errored
            testCase.QM.clearFilters();

            testCase.verifyNumElements(1, testCase.QM.numFiles);

            testCase.verifyError(...
                @() testCase.QM.filter(), "go:NoFiltersSet");
        end
    end

    methods (Test)
        function NameFilter(testCase)
            % Clear filters in case prior method errored
            testCase.QM.clearFilters();

            NF1 = aod.api.NameFilter(testCase.QM, 'ChannelOptimization');
            testCase.verifyEqual(nnz(NF1.apply()),1);

            NF2 = aod.api.NameFilter(testCase.QM, @(x) endsWith(x, 'Optimization'));
            testCase.verifyEqual(nnz(NF2.apply()),1);

            NF3 = aod.api.NameFilter(testCase.QM, 'BadName');
            testCase.verifyWarning(...
                @(x) NF3.apply(), "apply:NoMatches");
        end

        function ClassFilter(testCase)
            % Clear filters in case prior method errored
            testCase.QM.clearFilters();

            % There should always be just one Experiment per file
            CF1 = aod.api.ClassFilter(testCase.QM, 'aod.core.Experiment');
            idx = CF1.apply();
            testCase.verifyEqual(nnz(idx), 1);

            CF2 = aod.api.ClassFilter(testCase.QM, @(x) endsWith(x, 'Experiment'));
            idx = CF2.apply();
            testCase.verifyEqual(nnz(idx), 1);

            CF3 = aod.api.ClassFilter(testCase.QM, 'aod.core.BadClass');
            testCase.verifyWarning(@() CF3.apply(), 'apply:NoMatches');
        end

        function DatasetFilter(testCase)
            % Clear filters in case prior method errored
            testCase.QM.clearFilters();

            DF1 = aod.api.DatasetFilter(testCase.QM, 'epochIDs');
            idx = DF1.apply();
            testCase.verifyEqual(nnz(idx), 1);

            DF2 = aod.api.DatasetFilter(testCase.QM, 'epochIDs', [1 2]);
            idx = DF2.apply();
            testCase.verifyEqual(nnz(idx), 1);

            DF3 = aod.api.DatasetFilter(testCase.QM, 'epochIDs', [1 3]);
            testCase.verifyWarning(...
                @() DF3.apply(), 'apply:NoMatches');
        end

        function EntityFilter(testCase)
            % Clear filters in case prior method errored
            testCase.QM.clearFilters();

            % There should always be just one Experiment per file
            EF = aod.api.EntityFilter(testCase.QM, 'Experiment');
            testCase.QM.addFilter(EF);
            [matches, idx] = testCase.QM.filter();
            testCase.verifyEqual(numel(idx), 1);
            testCase.verifyEqual(height(matches), 1);

            % Test filter removal
            testCase.QM.removeFilter(1);
            testCase.verifyEqual(0, testCase.QM.numFilters);
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