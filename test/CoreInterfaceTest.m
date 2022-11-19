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
            cal1 = aod.core.Calibration('PowerMeasurement', '20220823');
            cal2 = aod.core.Calibration('PowerMeasurement', '20220825');

            testCase.EXPT.add(cal1);
            testCase.EXPT.add(cal2);
            testCase.verifyEqual(numel(obj.EXPT.Calibrations), 2);
            testCase.verifyEqual(...
                numel(obj.EXPT.getCalibration('aod.core.Calibration')), 2);
            
            testCase.EXPT.removeCalibration(1);
            testCase.verifyEqual(numel(obj.EXPT.Calibrations), 1);
            testCase.verifyEqual(obj.EXPT.Calibrations(1).UUID, cal2.UUID);

            testCase.EXPT.clearAllCalibrations();
            testCase.verifyEqual(numel(obj.EXPT.Calibrations), 0);
        end
    end
end 