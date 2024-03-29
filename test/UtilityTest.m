classdef UtilityTest < matlab.unittest.TestCase
% Test miscellaneous utility functions
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

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

%#ok<*MANU>

    properties
        EXPT
    end

    methods (TestClassSetup)
        function methodSetup(testCase)
            % Creates an experiment, writes to HDF5 and reads back in
            fileName = fullfile(getpref('AOData', 'BasePackage'), ...
                'test', 'ToyExperiment.h5');
            if ~exist(fileName, 'file')
                ToyExperiment(true, true);
            end
            testCase.EXPT = loadExperiment(fileName);
        end
    end

    methods (Test, TestTags=["Utility"])
        function Cohort(testCase)
            groupNames = aod.h5.getEntityGroupCohort(testCase.EXPT.Epochs(1));
            testCase.verifyNumElements(groupNames,2);
            testCase.verifyTrue(any(contains(groupNames, "0001")));
            testCase.verifyTrue(any(contains(groupNames, "0002")));
        end

        function Attributes(testCase)
            params = aod.common.KeyValueMap();
            params('A') = 1;
            map = params.toMap();
            testCase.verifyClass(map, 'containers.Map');

            S = params.toStruct();
            testCase.verifyClass(S, 'struct');
        end

        function EmptyKeyValueMap(testCase)
            obj = aod.common.KeyValueMap();
            toMap(obj)
        end

        function Factory(testCase)
            obj = aotest.TestFactory();
            testCase.verifyError(@() obj.create(), "create:NotImplemented");
        end

        function RepoManager(testCase)
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
                @() aod.infra.UUID.validate('baduuid'),...
                "validate:InvalidUUID");
        end

        function ValidateDate(testCase)
            testCase.verifyEmpty(aod.util.validateDate([]));

            testCase.verifyError(...
                @()aod.util.validateDate('BadDate'),...
                "validateDate:FailedDatetimeConversion");
        end

        function IsEntity(testCase)
            testCase.verifyFalse(aod.util.isEntity(123));
            [tf, persisted] = aod.util.isEntity(testCase.EXPT);
            testCase.verifyTrue(tf);
            testCase.verifyTrue(persisted);

            [tf, persisted] = aod.util.isEntity(aod.core.Device('MyDevice'));
            testCase.verifyTrue(tf);
            testCase.verifyFalse(persisted);
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

        function MustBeEpochID(testCase)
            expt = aod.core.Experiment('Test', cd, '20221226');
            expt.add(aod.core.Epoch(6));
            testCase.verifyError(...
                @() aod.util.mustBeEpochID(expt, 10),...
                "mustBeEpochID:UnmatchedID");
            % No error
            aod.util.mustBeEpochID(expt, 6);
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
                @() aod.util.findFileReader('RoiSet.zip'),...
                "findFileReader:UnknownExtension");
        end
    end

    methods (Test, TestTags=["Metaclass", "Utility"])
        function PropDescription(testCase)
            epoch1 = aod.core.Epoch(1);
            testCase.verifyEqual(...
                aod.specification.util.getClassPropDescription(epoch1, 'ID'),...
                aod.specification.util.getClassPropDescription(metaclass(epoch1), 'ID'));
            testCase.verifyError(...
                @() aod.specification.util.getClassPropDescription(epoch1, 'BadName'),...
                "getClassPropDescription:PropertyNotFound");
        end
    end

    methods (Test, TestTags=["FileManager", "Utility"])
        function FileManager(testCase)
            FM = aotest.TestFileManager(fullfile(...
                aotest.util.getAODataTestFolder(), 'test_data'));

            files = FM.getFilesFound();
            % ! This will change with # of test data files
            testCase.verifyNumElements(files, 12);

            out = FM.checkFilesFound(files, 1);
            testCase.verifyEqual(out, files(1));
            out = FM.checkFilesFound(files);
            testCase.verifyEqual(out, files(end));

            FM.setErrorType(aod.infra.ErrorTypes.ERROR);
            testCase.verifyEqual(...
                FM.messageLevel, aod.infra.ErrorTypes.ERROR);
        end
    end
end