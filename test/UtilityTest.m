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
% -------------------------------------------------------------------------

    methods (Test)
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

        function testUUIDValidation(testCase)
            testCase.verifyError(...
                @() aod.util.validateUUID('baduuid'),...
                "validateUUID:InvalidInput");
        end
    end
end 