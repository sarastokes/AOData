classdef SyncTest < matlab.unittest.TestCase 
% SYNCTEST
%
% Description:
%   Tests validation when a new entity is added to the core interface
%
% Parent:
%    matlab.unittest.TestCase
%
% Use:
%   result = runtests('SyncTest.m')
%
% See also:
%   runAODataTestSuite
% -------------------------------------------------------------------------

    properties
        EXPT 
    end

    methods (TestClassSetup)
        function methodSetup(testCase)
            testCase.EXPT = ToyExperiment(false);
        end
    end

    methods (Test)
        % TODO: UUID check
        function testGroupNameSimilarityCheck(testCase)
            cal1 = aod.core.Calibration('SameName', getDateYMD());
            cal2 = aod.core.Calibration('SameName', getDateYMD());
            testCase.EXPT.add(cal1);
            testCase.verifyWarning(@() testCase.EXPT.add(cal2), ...
                "Entity:DuplicateGroupName");
        end

        function propertyCheck(testCase)
            aod.h5.getPersistedProperties(testCase.EXPT, true);
        end

        function testLinkedEntitySync(testCase)
            cal = aod.core.Calibration('test1', '20220902');
            cal.setTarget(aod.core.System('externalSource'));
            testCase.verifyWarning(@() testCase.EXPT.add(cal), ...
                "Entity:SyncWarning");
            
            cal = aod.core.Calibration('test2', '20220902');
            cal.setTarget(testCase.EXPT.Systems(1));
            testCase.verifyWarningFree(@() testCase.EXPT.add(cal));
        end
    end
end 