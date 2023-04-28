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
        function Parameters(testCase)
            params = aod.util.Parameters();
            params('A') = 1;
            map = params.toMap();
            testCase.verifyClass(map, 'containers.Map');
        end

        function Factory(testCase)
            obj = test.TestFactory();
            testCase.verifyError(@() obj.create(), "create:NotImplemented");
        end

        function RepoManager(testCase) %#ok<MANU> 
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

    methods (Test, TestTags=["Parameters", "Utility"])
        function ParamManager(testCase)
            PM = aod.util.ParameterManager();
            testCase.verifyEqual(PM.Count, 0);
            testCase.verifyEmpty(PM.table());

            % Add param info
            PM.add('MyParam1');
            testCase.verifyEqual(PM.Count, 1);
            testCase.verifyTrue(PM.hasParam('MyParam1'));

            % Error for existing parameter
            testCase.verifyError(@() PM.add('MyParam1'), "add:ParameterExists");

            % Add an ExpectedParameter
            EP = aod.util.templates.ExpectedParameter('MyParam2');
            PM.add(EP);
            testCase.verifyEqual(PM.Count, 2);
            testCase.verifyEqual(height(PM.table()), 2);

            % Add a ParameterManager
            PM2 = aod.util.ParameterManager();
            PM2.add(PM);
            testCase.verifyEqual(PM2.Count, 2);
            
            % Remove parameters
            PM.remove('MyParam1');
            testCase.verifyEqual(PM.Count, 1);
            testCase.verifyFalse(PM.hasParam('MyParam1'));

            % Warning for wrong parameter name
            testCase.verifyWarning(...
                @() PM.remove('BadParamName'), "remove:ParamNotFound");

            % Clear parameters
            PM2.clear();
            testCase.verifyEqual(PM2.Count, 0);

            % No error for empty parameter manager
            PM2.remove('MyParam1');
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
                aod.util.getClassPropDescription(epoch1, 'ID'),...
                aod.util.getClassPropDescription(metaclass(epoch1), 'ID'));
            testCase.verifyError(...
                @() aod.util.getClassPropDescription(epoch1, 'BadName'),...
                "getClassPropDescription:PropertyNotFound");
        end
    end

    methods (Test, TestTags=["FileManager", "Utility"])
        function FileManager(testCase)
            FM = test.TestFileManager(fullfile(...
                test.util.getAODataTestFolder(), 'test_data'));
            
            files = FM.getFilesFound();
            % ! This will change with # of test data files
            testCase.verifyNumElements(files, 8);

            out = FM.checkFilesFound(files, 1);
            testCase.verifyEqual(out, files(1));
            out = FM.checkFilesFound(files);
            testCase.verifyEqual(out, files(end));

            FM.setErrorType(aod.util.ErrorTypes.ERROR);
            testCase.verifyEqual(...
                FM.messageLevel, aod.util.ErrorTypes.ERROR);
        end
    end
end 