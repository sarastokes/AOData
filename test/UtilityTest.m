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

        function Factory(testCase)
            obj = test.TestFactory();
            testCase.verifyError(@() obj.create(), "create:NotImplemented");
        end

        function testRepoManager(testCase)
            RM = aod.infra.RepositoryManager();
            RM.listPackages();
            RM.update();
        end

        function FindByUUID(testCase)
            % Confirm no error when entities is empty
            [entity, idx] = aod.util.findByUUID(aod.core.Calibration.empty(), "d18642a3-745a-4d63-ae26-3c8e1d87c944");
            testCase.verifyEmpty(entity);
            testCase.verifyEmpty(idx);
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

    methods (Test, TestTags=["Argument", "Utility"])
        function MustBeEntity(testCase)
            testCase.verifyError(...
                @() aod.util.mustBeEntity(123), "mustBeEntity:InvalidInput");
            % Should produce no error
            aod.util.mustBeEntity([aod.core.Epoch(1), aod.core.Epoch(2)]);
        end

        function MustBeEntityType(testCase)
            testCase.verifyError(...
                @() aod.util.mustBeEntityType(aod.core.Epoch(1), 'Device'),...
                "mustBeEntityType:InvalidEntityType");
            % Should produce no error
            aod.util.mustBeEntityType([aod.core.Epoch(1), aod.core.Epoch(2)], 'Epoch');
        end
    end

    methods (Test, TestTags=["Files", "Utility"])
        function FindFileReader(testCase)
            testCase.verifyClass(aod.util.findFileReader('test.avi'),...
                'aod.util.readers.AviReader');
            testCase.verifyClass(aod.util.findFileReader('test.tif'),...
                'aod.util.readers.TiffReader');
            testCase.verifyClass(aod.util.findFileReader('test.json'),...
                'aod.util.readers.JsonReader');
            testCase.verifyClass(aod.util.findFileReader('test.mat'),...
                'aod.util.readers.MatReader');
            testCase.verifyClass(aod.util.findFileReader('test.png'),...
                'aod.util.readers.ImageReader');
            
            testCase.verifyError(...
                @() aod.util.findFileReader('test.zip'),...
                "findFileReader:UnknownExtension");
        end

        function FileManagerClass(testCase)
            %obj1 = test.FileManager(pwd);
            %obj2 = test.FileManager([pwd, filesep]);

            % Check trailing filesep handling
            %testCase.verifyEqual(obj1.baseFolderPath, obj2.baseFolderPath);
        end
    end 

    methods (Test, TestTags=["Metaclass", "Utility"])
        function PropDescription(testCase)
            epoch1 = aod.core.Epoch(1);
            testCase.verifyEqual(...
                aod.util.getClassPropDescription(epoch1, 'ID'),...
                aod.util.getClassPropDescription(metaclass(epoch1), 'ID'));
            testCase.verifyError(...
                @() aod.util.getClassPropDescription(epoch1, 'BadName'),...
                "getClassPropDescription:PropertyNotFound");
        end
    end
end 