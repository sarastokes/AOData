classdef UtilityTest < matlab.unittest.TestCase
% UTILITYTEST
%
% Description:
%   Tests AOData utility functions
%
% Parent:
%   matlab.unittest.TestCase
%
% Use:
%   result = runtests('UtilityTest.m')
%
% See also:
%   runAODataTestSuite

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    methods (Test, TestTags=["Utility"])
        function testParameters(testCase)
            params = aod.util.Parameters();
            params('A') = 1;
            map = params.toMap();
            testCase.verifyClass(map, 'containers.Map');
        end

        function testRepoManager(testCase)
            RM = aod.infra.RepositoryManager();
            RM.listPackages();
            RM.update();
        end

    end

    methods (Test, TestTags=["Validation", "Utility"])
        function ValidateUUID(testCase)
            testCase.verifyError(...
                @() aod.util.validateUUID('baduuid'),...
                "validateUUID:InvalidInput");
        end

        function ValidateDate(testCase)
            testCase.verifyEmpty(aod.util.validateDate([]));

            testCase.verifyError(...
                @()aod.util.validateDate('BadDate'),... 
                "validateDate:FailedDatetimeConversion");
        end
    end
end 