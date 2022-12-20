classdef CoreApiTest < matlab.unittest.TestCase
% COREINTERFACETEST
%
% Description:
%   Tests API for filtering entities in the core interface
%
% Parent:
%   matlab.unittest.TestCase
%
% Use:
%   result = runtests('CoreApiTest.m')
%
% See Also:
%   runAODataTestSuite, aod.core.EntitySearch

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties
        EXPT
    end

    methods (TestClassSetup)
        function methodSetup(testCase)
            testCase.EXPT = aod.core.Experiment(...
                '851_20221117', cd, '20221117',...
                'Administrator', 'Sara Patterson',... 
                'Laboratory', '1P Primate');

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

            % Add epochs with a few parameters and files
            epochIDs = [1, 2, 6, 7, 8, 9];
            pmtGains = [0.491, 0.5, 0.51, 0.51, 0.515, 0.515];
            for i = 1:numel(epochIDs)
                testCase.EXPT.add(aod.core.Epoch(i));
                % Don't add a parameter and file to the last epoch
                if i ~= numel(epochIDs)
                    testCase.EXPT.Epochs(i).setParam('PmtGain', pmtGains(i));
                end
                if i > 2
                    testCase.EXPT.Epochs(i).setFile('MyFile', 'test.txt');
                elseif i == 1
                    testCase.EXPT.Epochs(end).setFile('MyFile', '');
                end
            end
        end
    end

    methods (Test)
        function testEmptySearch(testCase)
            testCase.verifyWarning(...
                @() aod.core.EntitySearch.go('Response'),...
                "go:NoQueries");
        end

        function testNameSearch(testCase)
            out = testCase.EXPT.get('Analysis',...
                {'Name', 'Analysis1'});
            testCase.verifyNumElements(out, 1);

            out = testCase.EXPT.get('Analysis',...
                {'Name', @(x) contains(x, 'Analysis')});
            testCase.verifyNumElements(out, 2);
        end

        function testSubclassSearch(testCase)
            out = testCase.EXPT.get('Calibration',...
                {'Subclass', 'aod.core.Calibration'});
            testCase.verifyNumElements(out, 2);
        end

        function testClassSearch(testCase)
            egObj = aod.core.EntitySearch(testCase.EXPT.Calibrations,...
                {'Class', 'aod.builtin.calibrations.PowerMeasurement'});
            testCase.verifyEqual(numel(egObj.getMatches()), 1);
        end


        function testDatasetSearch(testCase)
            % Test for presence of a dataset
            out = aod.core.EntitySearch.go(testCase.EXPT.Calibrations,...
                {'Dataset', 'measurements'});
            testCase.verifyNumElements(out, 1);

            out = testCase.EXPT.get('Epochs', {'Dataset', 'ID', 1});
            testCase.verifyNumElements(out, 1);

            out = testCase.EXPT.get('Epochs', {'Dataset', 'ID', @(x) x < 3});
            testCase.verifyNumElements(out, 2);
        end

        function testParameterSearch(testCase)
            % Match param presence
            out = testCase.EXPT.get('Epoch',...
                {'Parameter', 'PmtGain'});
            testCase.verifyNumElements(out, 5);

            % Match param values
            out = testCase.EXPT.get('Epoch',...
                {'Parameter', 'PmtGain', 0.5});
            testCase.verifyNumElements(out, 1);

            % Match param values using a function handle
            out = testCase.EXPT.get('Epoch',...
                {'Parameter', 'PmtGain', @(x) x < 0.505});
            testCase.verifyNumElements(out, 2);
        end

        function testFileSearch(testCase)
            % Match file presence
            out = aod.core.EntitySearch.go(testCase.EXPT.Epochs,...
                {'File', 'MyFile'});
            testCase.verifyNumElements(out, 5);

            % Match files values using a function handle
            egObj = aod.core.EntitySearch(testCase.EXPT.Epochs,...
                {'File', 'MyFile', @(x) endsWith(x, '.txt')});
            testCase.verifyEqual(numel(egObj.getMatches()), 4);
        end
    end
end
