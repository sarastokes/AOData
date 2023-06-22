classdef HdfTest < matlab.unittest.TestCase
% Test AOData-specific HDF5 IO
%
% Description:
%   Test HDF5 I/O specific to AOData, rest is handed in h5tools-matlab
%
% Parent:
%   matlab.unittest.TestCase
%
% Use:
%   result = runtests('HdfTest')
%
% See also:
%   runAODataTestSuite

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------
    properties
        dataFolder
        FILE 
    end

    methods (TestClassSetup)
        function methodSetup(testCase)
            testCase.dataFolder = fullfile(fileparts(mfilename('fullpath')), 'test_data');
            testCase.FILE = fullfile(test.util.getAODataTestFolder(), 'HDFTest.h5');
            % Create a test file, overwrite if exists
            h5tools.createFile(testCase.FILE, true);
        end
    end

    methods (Test)
        function PropertyHandling(testCase)
            obj = test.TestDevice();

            [dsetProps, attProps, abandonedProps] = ...
                aod.h5.getPersistedProperties(obj);

            % Ensure empty properties are not flagged for persistence
            testCase.verifyTrue(ismember('EmptyProp', abandonedProps));
            testCase.verifyFalse(ismember('EmptyProp', dsetProps));

            % Ensure dependent props are persisted unless hidden
            testCase.verifyTrue(ismember('DependentProp', dsetProps));
            testCase.verifyFalse(ismember('HiddenDependentProp', dsetProps));
        end

        function FileReader(testCase)
            reader = aod.util.readers.CsvReader(...
                fullfile(testCase.dataFolder, 'test.csv'));
            % Write the dataset
            aod.h5.write(testCase.FILE, '/', 'FileReader', reader);
            % Read the dataset
            reader0 = aod.h5.read(testCase.FILE, '/', 'FileReader');
            testCase.verifyEqual(reader, reader0);
        end 

        function FileReaderWithData(testCase)
            reader = aod.builtin.readers.ImageJRoiReader(...
                fullfile(test.util.getAODataTestFolder(), 'test_data', 'RoiSet.zip'), [242, 360]);
            % Write the dataset
            aod.h5.write(testCase.FILE, '/', 'RoiReader', reader);
            % Read the dataset
            reader0 = aod.h5.read(testCase.FILE, '/', 'RoiReader');
            % Test for equality
            testCase.verifyEqual(reader, reader0);
        end

        function AttributeManager(testCase)
            AM = aod.specification.util.getAttributeSpecification(...
                "aod.builtin.devices.DichroicFilter");
            % Write the dataset
            aod.h5.write(testCase.FILE, '/', 'expectedAttributes', AM);
            % Read the dataset
            AM0 = aod.h5.read(testCase.FILE, '/', 'expectedAttributes');
            % Test for equality
            testCase.verifyEqual(AM, AM0);
        end

        function DatasetManager(testCase)
            DM = aod.specification.util.getDatasetSpecification(...
                "aod.core.Epoch");
            % Write the dataset
            aod.h5.write(testCase.FILE, '/', 'expectedDatasets', DM);
            % Read the dataset
            DM0 = aod.h5.read(testCase.FILE, '/', 'expectedDatasets');
            % Test for equality
            testCase.verifyEqual(DM, DM0);
        end
    end
end