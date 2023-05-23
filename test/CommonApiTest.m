classdef CommonApiTest < matlab.unittest.TestCase
% Test search capabilitites in the common interface
%
% Description:
%   Tests API for filtering entities in the common interface
%
% Parent:
%   matlab.unittest.TestCase
%
% Use:
%   result = runtests('CommonApiTest.m')
%
% See Also:
%   runAODataTestSuite, aod.common.EntitySearch, CoreInterfaceTest

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties
        EXPT
        PRST
    end

    methods (TestClassSetup)
        function methodSetup(testCase)
            % Set up an experiment with:
            % - 2 Calibrations (base & PowerMeasurement)
            % - 1 System 
            % - 2 Analyses
            % - 6 Epochs w/ varying attributes & files
            % - 4 Registrations ('RegType1' on 1/2, 'RegType2' on 6/7)
            % - 3 EpochDatasets ('Dset1' on 1/2, 'Dset2' on 1)

            testCase.EXPT = aod.core.Experiment(...
                '851_20221117', cd, '20221117',...
                'Administrator', "Sara Patterson",... 
                'Laboratory', "1P Primate");

            % Add calibrations (two classes)
            testCase.EXPT.add(aod.core.Calibration(...
                'TestCalibration1', getDateYMD()));
            testCase.EXPT.add(aod.builtin.calibrations.PowerMeasurement(...
                'Mustang', getDateYMD(), 488));

            % Add a system
            testCase.EXPT.add(aod.core.System('TestSystem1'));
            testCase.EXPT.Systems(1).add(aod.core.Channel('TestChannel1'));
            testCase.EXPT.Systems(1).Channels(1).add(...
                aod.builtin.devices.DichroicFilter(510, 'Low'));

            % Add analyses
            testCase.EXPT.add(aod.core.Analysis('Analysis1'));
            testCase.EXPT.add(aod.core.Analysis('Analysis2'));

            % Add epochs with a few attributes and files
            epochIDs = [1, 2, 6, 7, 8, 9];
            pmtGains = [0.491, 0.5, 0.51, 0.51, 0.515, 0.515];
            for i = 1:numel(epochIDs)
                testCase.EXPT.add(aod.core.Epoch(i));
                % Don't add a attribute and file to the last epoch
                if i ~= numel(epochIDs)
                    testCase.EXPT.Epochs(i).setAttr('PmtGain', pmtGains(i));
                end
                if i > 2
                    testCase.EXPT.Epochs(i).setFile('MyFile', 'test.txt');
                elseif i == 1
                    testCase.EXPT.Epochs(end).setFile('MyFile', '');
                end
            end

            testCase.EXPT.Epochs(1).add(aod.core.Registration('RegType1'));
            testCase.EXPT.Epochs(2).add(aod.core.Registration('RegType1'));
            testCase.EXPT.Epochs(3).add(aod.core.Registration('RegType2'));
            testCase.EXPT.Epochs(4).add(aod.core.Registration('RegType2'));

            testCase.EXPT.Epochs(1).add(aod.core.EpochDataset('Dset1'));
            testCase.EXPT.Epochs(1).add(aod.core.EpochDataset('Dset2'));
            testCase.EXPT.Epochs(2).add(aod.core.EpochDataset('Dset1'));

            aod.h5.writeExperimentToFile("CommonApiTest.h5", testCase.EXPT, true);
            testCase.PRST = loadExperiment("CommonApiTest.h5");
        end
    end

    methods (Test)
        function EmptySearch(testCase)
            testCase.verifyWarning(...
                @() aod.common.EntitySearch.go('Response'), "go:NoQueries");
        end

        function NameSearch(testCase)
            out = testCase.EXPT.get('Analysis',...
                {'Name', 'Analysis1'});
            testCase.verifyNumElements(out, 1);

            out = testCase.EXPT.get('Analysis',...
                {'Name', @(x) contains(x, 'Analysis')});
            testCase.verifyNumElements(out, 2);
        end

        function SubclassSearch(testCase)
            out = testCase.EXPT.get('Calibration',...
                {'Subclass', 'aod.core.Calibration'});
            testCase.verifyNumElements(out, 2);
        end

        function ClassSearch(testCase)
            egObj = aod.common.EntitySearch(testCase.EXPT.Calibrations,...
                {'Class', 'aod.builtin.calibrations.PowerMeasurement'});
            testCase.verifyEqual(numel(egObj.getMatches()), 1);
        end

        function DatasetSearch(testCase)
            % Test for presence of a dataset
            out = aod.common.EntitySearch.go(testCase.EXPT.Calibrations,...
                {'Dataset', 'measurements'});
            testCase.verifyNumElements(out, 1);

            out = testCase.EXPT.get('Epochs', {'Dataset', 'ID', 1});
            testCase.verifyNumElements(out, 1);

            out = testCase.EXPT.get('Epochs', {'Dataset', 'ID', @(x) x < 3});
            testCase.verifyNumElements(out, 2);
        end

        function FirstMatchWarnings(testCase)
            testCase.verifyWarning(...
                @() aod.common.EntitySearch(testCase.EXPT.Calibrations, {'Attribute', 'BadParamName', 1}),...
                "attributeQuery:NoParamNameMatches");
            testCase.verifyWarning(...
                @() aod.common.EntitySearch(testCase.EXPT.Calibrations, {'Dataset', 'BadDatasetName', 1}),...
                "datasetQuery:NoDsetNameMatches");
            testCase.verifyWarning(...
                @() aod.common.EntitySearch(testCase.EXPT.Calibrations, {'File', 'BadFileName', 'test.txt'}),...
                "fileQuery:NoFileNameMatches");
        end

        function EmptyInput(testCase)
            testCase.verifyEmpty(aod.common.EntitySearch.go(...
                testCase.EXPT.Analyses, {'Attribute', 'MyParam'}));
        end

        function testAttributeSearch(testCase)
            % Match param presence
            out = testCase.EXPT.get('Epoch',...
                {'Attribute', 'PmtGain'});
            testCase.verifyNumElements(out, 5);

            % Match param values
            out = testCase.EXPT.get('Epoch',...
                {'Attribute', 'PmtGain', 0.5});
            testCase.verifyNumElements(out, 1);

            % Match param values using a function handle
            out = testCase.EXPT.get('Epoch',...
                {'Attribute', 'PmtGain', @(x) x < 0.505});
            testCase.verifyNumElements(out, 2);
        end

        function GetAttrWithMissing(testCase)
            % Nonscalar attribute search with missing entities
            out = testCase.EXPT.Epochs.getAttr('PmtGain');
            testCase.verifyNumElements(out, numel(testCase.EXPT.Epochs));
            testCase.verifyEqual(nnz(ismissing(out)), 1);
            % Here because the class setup is good for this test
        end

        function testFileSearch(testCase)
            % Match file presence
            outC = aod.common.EntitySearch.go(testCase.EXPT.Epochs,...
                {'File', 'MyFile'});
            testCase.verifyNumElements(outC, 5);
            outP = aod.common.EntitySearch.go(testCase.EXPT.Epochs,...
                {'File', 'MyFile'});
            testCase.verifyNumElements(outP, 5);

            % Match files values using a function handle
            egObjC = aod.common.EntitySearch(testCase.EXPT.Epochs,...
                {'File', 'MyFile', @(x) endsWith(x, '.txt')});
            testCase.verifyNumElements(egObjC.getMatches(), 4);
            egObjP = aod.common.EntitySearch(testCase.PRST.Epochs,...
                {'File', 'MyFile', @(x) endsWith(x, '.txt')});
            testCase.verifyNumElements(egObjP.getMatches(), 4);

            % Match files by name
            egObjC = aod.common.EntitySearch(testCase.EXPT.Epochs,...
                {'File', 'MyFile', 'test.txt'});
            testCase.verifyNumElements(egObjC.getMatches(), 4);
            egObjP = aod.common.EntitySearch(testCase.PRST.Epochs,...
                {'File', 'MyFile', 'test.txt'});
            testCase.verifyNumElements(egObjP.getMatches(), 4);
        end

        function GetFileWithMissing(testCase)
            % Nonscalar file search with missing entities
            out = testCase.EXPT.Epochs.getFile('MyFile');
            testCase.verifyNumElements(out, numel(testCase.EXPT.Epochs));
            testCase.verifyEqual(nnz(ismissing(out)), 2);
            % Here because the class setup is good for this test
        end
    end

    methods (Test, TestTags=["CoreApi"])
        function EmptyEpochs(testCase)
            testCase.verifyNumElements(...
                testCase.EXPT.getFromEpoch('all', 'Registration'), 4);
            testCase.verifyNumElements(...
                testCase.EXPT.getFromEpoch([], 'Registration'), 4);
        end

        function SubEpochEntities(testCase)
            out = testCase.EXPT.getFromEpoch('all', 'EpochDataset', 1);
            testCase.verifyNumElements(out, 1);
            testCase.verifyTrue(strcmp(out.Name, 'Dset1'));
            
            out = testCase.EXPT.getFromEpoch(...
                'all', 'Registration', {'Name', 'RegType1'});
            testCase.verifyNumElements(out, 2);
        end
    end

    methods (Test, TestTags=["Errors", "CoreApi"])
        function EntityErrors(testCase)
            testCase.verifyError(...
                @() testCase.EXPT.Systems(1).Channels(1).get('Epoch'),...
                "get:InvalidEntityType");
            testCase.verifyError(...
                @() testCase.EXPT.Epochs(1).get('System'),...
                "get:InvalidEntityType");
            testCase.verifyError(...
                @() testCase.PRST.Epochs(1).get('System'),...
                "get:InvalidEntityType");
        end
        
        function IDErrors(testCase)
            testCase.verifyError(...
                @() testCase.EXPT.Systems(1).remove('Channel', 'BadID'),...
                "remove:InvalidID");
        end
    end
end
