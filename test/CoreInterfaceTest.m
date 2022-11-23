classdef CoreInterfaceTest < matlab.unittest.TestCase 
% COREINTERFACETEST
%
% Description:
%   Tests adding, searching and removing entities to an Experiment
%
% Parent:
%   matlab.unittest.TestCase
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
        end
    end

    methods (Test)
        function calibrationIO(testCase)
            % Add a first calibration
            cal1 = aod.core.Calibration('PowerMeasurement1', '20220823');
            testCase.EXPT.add(cal1);
            testCase.verifyEqual(numel(testCase.EXPT.Calibrations), 1);

            % Add a second calibration
            cal2 = aod.core.Calibration('PowerMeasurement2', '20220825');
            testCase.EXPT.add(cal2);
            testCase.verifyEqual(numel(testCase.EXPT.Calibrations), 2);

            % Indexing
            testCase.verifyEqual(cal2.UUID, testCase.EXPT.Calibrations(2).UUID);

            % Access calibrations
            calOut = testCase.EXPT.getCalibration('aod.core.Calibration');
            testCase.verifyEqual(numel(calOut), 2);
            
            % Remove a single calibraiton
            testCase.EXPT.removeCalibration(1);
            testCase.verifyEqual(numel(testCase.EXPT.Calibrations), 1);
            testCase.verifyEqual(testCase.EXPT.Calibrations(1).UUID, cal2.UUID);

            % Clear all existing calibrations
            testCase.EXPT.clearCalibrations();
            testCase.verifyEqual(numel(testCase.EXPT.Calibrations), 0);
        end

        function analysisIO(testCase)
            analysis1 = aod.core.Analysis('TestAnalysis1', 'Date', getDateYMD());
            
            % Add an experiment
            testCase.EXPT.add(analysis1);
            testCase.verifyEqual(numel(testCase.EXPT.Analyses), 1);

        end
    end
end 