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
        
        SMALL_EXPT
        SMALL_QM
    end

    methods (TestClassSetup)
        function methodSetup(testCase)
            testDir = test.util.getAODataTestFolder();

            % Creates an experiment, writes to HDF5 and reads back in
            testCase.FILENAME = fullfile(testDir, 'ToyExperiment.h5');
            if ~exist(testCase.FILENAME, 'file')
                [~, testCase.EXPT] = ToyExperiment(true, true);
            end
            testCase.QM = aod.api.QueryManager(testCase.FILENAME);

            % Make a small experiment with missing entity types
            expt = aod.core.Experiment('SmallExperiment', testDir, getDateYMD());
            aod.h5.writeExperimentToFile(...
                fullfile(testDir, 'SmallExperiment.h5'), expt, true);
            testCase.SMALL_EXPT = loadExperiment(fullfile(testDir, 'SmallExperiment.h5'));
            testCase.SMALL_QM = aod.api.QueryManager(testCase.SMALL_EXPT);
        end
    end
    
    methods 
        function reset(testCase)
            % Clear filters in case prior method errored
            testCase.QM.clearFilters();
        end
    end

    methods (Test, TestTags=["QueryManager", "AOQuery"])
        function QueryManagerErrors(testCase)
            testCase.reset();

            testCase.verifyError(...
                @() testCase.QM.filter(), "go:NoFiltersSet");

            testCase.verifyError(...
                @() testCase.QM.addFilter(1), "addFilter:InvalidInput");

            testCase.verifyError(...
                @() aod.api.QueryManager(1),...
                "QueryManager:InvalidInput");
        end

        function QueryFiles(testCase)
            testCase.reset();
            testCase.verifyNumElements(1, testCase.QM.numFiles);
        end

        function FilterAddition(testCase)
            % Clear filters in case prior method errored
            testCase.QM.clearFilters();
            
            testCase.QM.addFilter({'Name', '0001'});
            testCase.verifyEqual(1, testCase.QM.numFilters);
            testCase.verifyEqual(height(testCase.QM.filter()), 1);
        end
    end

    methods (Test, TestTags=["NameFilter", "AOQuery"])
        function NameFilter(testCase)
            testCase.reset();

            NF1 = aod.api.NameFilter(testCase.QM, 'ChannelOptimization');
            testCase.verifyFalse(NF1.didFilter);
            testCase.verifyEqual(nnz(NF1.apply()),1);
            testCase.verifyTrue(NF1.didFilter);

            NF2 = aod.api.NameFilter(testCase.QM, @(x) endsWith(x, 'Optimization'));
            testCase.verifyEqual(nnz(NF2.apply()),1);
            % Alt initialization
            testCase.QM.addFilter({'Name', @(x) endsWith(x, 'Optimization')});
            testCase.verifyEqual(height(testCase.QM.filter()), 1);
        end

        function NameFilterWarnings(testCase)
            testCase.reset();

            NF3 = aod.api.NameFilter(testCase.QM, 'BadName');
            testCase.verifyWarning(...
                @(x) NF3.apply(), "apply:NoMatches");
        end
    end

    methods (Test, TestTags=["ClassFilter", "AOQuery"])
        function ClassFilter(testCase)
            testCase.reset();

            % There should always be just one Experiment per file
            CF1 = aod.api.ClassFilter(testCase.QM, 'aod.core.Experiment');
            idx = CF1.apply();
            testCase.verifyEqual(nnz(idx), 1);

            CF2 = aod.api.ClassFilter(testCase.QM, @(x) endsWith(x, 'Experiment'));
            idx = CF2.apply();
            testCase.verifyEqual(nnz(idx), 1);
            % Alt initialization
            testCase.QM.addFilter({'Class', @(x) endsWith(x, 'Experiment')});
            testCase.verifyEqual(height(testCase.QM.filter()), 1);
        end

        function ClassFilterWarnings(testCase)
            testCase.reset();

            CF3 = aod.api.ClassFilter(testCase.QM, 'aod.core.BadClass');
            testCase.verifyWarning(@() CF3.apply(), 'apply:NoMatches');
        end
    end

    methods (Test, TestTags=["DatasetFilter", "AOQuery"])
        function DatasetFilter(testCase)
            testCase.reset();

            DF1 = aod.api.DatasetFilter(testCase.QM, 'epochIDs');
            idx = DF1.apply();
            testCase.verifyEqual(nnz(idx), 1);

            DF2 = aod.api.DatasetFilter(testCase.QM, 'epochIDs', [1 2]);
            idx = DF2.apply();
            testCase.verifyEqual(nnz(idx), 1);
            % Alt initialization
            testCase.QM.addFilter({'Dataset', 'epochIDs', [1 2]});
            testCase.verifyEqual(height(testCase.QM.filter()), 1);

        end

        function DatasetFilterWarnings(testCase)
            testCase.reset();

            DF3 = aod.api.DatasetFilter(testCase.QM, 'epochIDs', [1 3]);
            testCase.verifyWarning(...
                @() DF3.apply(), 'apply:NoMatches');
        end

    end

    methods (Test, TestTags=["EntityFilter", "AOQuery"])
        function EntityFilter(testCase)
            testCase.reset();

            % There should always be just one Experiment per file
            EF = aod.api.EntityFilter(testCase.QM, 'Experiment');
            testCase.QM.addFilter(EF);
            [matches, idx] = testCase.QM.filter();
            testCase.verifyEqual(numel(idx), 1);
            testCase.verifyEqual(height(matches), 1);
            % Alt initialization
            testCase.QM.addFilter({'Entity', 'Experiment'});
            testCase.verifyEqual(height(testCase.QM.filter()), 1);

            % Test filter removal
            testCase.QM.removeFilter(1);
            testCase.verifyEqual(testCase.QM.numFilters, 1);

            % Test filter clearing
            testCase.QM.clearFilters();
            testCase.verifyEqual(testCase.QM.numFilters, 0);
            testCase.verifyEmpty(testCase.QM.Filters);
        end

        function EntityFilterWarnings(testCase)
            testCase.reset();

            EF = aod.api.EntityFilter(testCase.SMALL_QM, 'Epoch');
            testCase.verifyWarning(...
                @() EF.apply(), 'apply:NoMatches');
        end
    end

    methods (Test, TestTags=["ChildFilter", "AOQuery"])
        function ChildFilter(testCase)
            testCase.reset();
            
            CF = aod.api.ChildFilter(testCase.QM, 'Response',... 
                {'Dataset', 'Data', [2 4 6 8]});
            idx = CF.apply();
            testCase.verifyEqual(nnz(idx), 1);
            testCase.verifyTrue(endsWith(CF.getMatchedGroups(), "0001"));
        end

        function ChildFilterWarnings(testCase)
            testCase.reset();

            CF = aod.api.ChildFilter(testCase.QM, 'Analysis',...
                {'Name', 'BadAnalysisName'});
            testCase.verifyWarning(...
                @() CF.apply, "apply:NoMatches");
        end
    end

    methods (Test, TestTags=["LinkFilter", "AOQuery"])
        function LinkFilter(testCase)
            testCase.reset();

            LF = aod.api.LinkFilter(testCase.QM, 'Source');
            testCase.verifyEqual(nnz(LF.apply()), 2);
        end

        function LinkFilterWarnings(testCase)
            testCase.reset();

            LF = aod.api.LinkFilter(testCase.QM, 'BadLink');
            testCase.verifyWarning(...
                @()LF.apply, "apply:NoMatches");
        end

        function LinkFilterErrors(testCase)
            testCase.reset();

            testCase.verifyError(...
                @() aod.api.LinkFilter(testCase.QM, 'Parent'),...
                'LinkFilter:ParentInvalid');
        end
    end
    
    methods (Test, TestTags=["ParentFilter", "AOQuery"])
        function ParentFilter(testCase)
            testCase.reset();

            % Get responses with parent Epoch that has Epoch ID 1
            PF = aod.api.ParentFilter(testCase.QM, 'Response', 'Epoch',...
                {'Dataset', 'ID', 1});
            testCase.verifyEqual(nnz(PF.apply()), 2);

            % Get Sources with Parent Source that has name ending in OS
            PF2 = aod.api.ParentFilter(testCase.QM, 'Source',...
                'Source', {'Name', @(x) endsWith(x, 'OS')});
            idx = PF2.apply();
            testCase.verifyEqual(nnz(idx), 1);
            testCase.verifyTrue(endsWith(PF2.getMatchedGroups(), "Right"));
        end

        function ParentFilterErrors(testCase)
            testCase.reset();

            testCase.verifyError(...
                @() aod.api.ParentFilter(testCase.QM, 'Epoch', 'Source'),...
                "ParentFilter:InvalidParentType");
        end
    end

    methods (Test, TestTags=["ParameterFilter", "AOQuery"])
        function ParameterFilter(testCase)
            testCase.reset();

            % Has parameter
            PF1 = aod.api.ParameterFilter(testCase.QM, 'Laboratory');
            idx = PF1.apply();
            testCase.verifyEqual(nnz(idx), 1);


            % Specific parameter value (match)
            PF2 = aod.api.ParameterFilter(testCase.QM,... 
                'Laboratory', "Primate-1P");
            idx = PF2.apply();
            testCase.verifyEqual(nnz(idx), 1);
            % Alt initialization
            testCase.QM.addFilter({'Parameter', 'Laboratory', 'Primate-1P'});
            testCase.verifyEqual(height(testCase.QM.filter()), 1);
        end

        function ParamterFilterWarnings(testCase)
            testCase.reset();

            % Has parameter, no match
            PF4 = aod.api.ParameterFilter(testCase.QM, 'BadParam');
            testCase.verifyWarning(...
                @() PF4.apply(), "apply:NoMatches");
            
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