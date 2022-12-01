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
%   result = runtests('CoreAoiTest.m')
%
% See also:
%   runAODataTestSuite
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
        function testSubclassSearch(testCase)
            egObj = aod.api.EntityGroupSearch(testCase.EXPT.Calibrations,... 
                'Class', 'aod.builtin.calibrations.PowerMeasurement');
            testCase.verifyEqual(numel(egObj.getMatches()), 1);
        end

        function testClassSearch(testCase)
            egObj = aod.api.EntityGroupSearch(testCase.EXPT.Calibrations,...
                'Subclass', 'aod.core.Calibration');
            testCase.verifyEqual(numel(egObj.getMatches()), 2);
        end

        function testParameterSearch(testCase)
            % Match param presence
            egObj = aod.api.EntityGroupSearch(testCase.EXPT.Epochs,...
                'Parameter', 'PmtGain');
            testCase.verifyEqual(numel(egObj.getMatches()), 5);

            % Match param values
            egObj = aod.api.EntityGroupSearch(testCase.EXPT.Epochs,...
                'Parameter', 'PmtGain', 0.5);
            testCase.verifyEqual(numel(egObj.getMatches()), 1);

            % Match param values using a function handle
            egObj = aod.api.EntityGroupSearch(testCase.EXPT.Epochs,...
                'Parameter', 'PmtGain', @(x) x < 0.505);
            testCase.verifyEqual(numel(egObj.getMatches()), 2);
        end

        function testFileSearch(testCase)
            % Match file presence
            egObj = aod.api.EntityGroupSearch(testCase.EXPT.Epochs,...
                'File', 'MyFile');
            testCase.verifyEqual(numel(egObj.getMatches()), 5);

            % Match files values using a function handle
            egObj = aod.api.EntityGroupSearch(testCase.EXPT.Epochs,...
                'File', 'MyFile', @(x) endsWith(x, '.txt'));
            testCase.verifyEqual(numel(egObj.getMatches()), 4);
        end
    end
end
