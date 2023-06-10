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
    end

    methods (TestClassSetup)
        function methodSetup(testCase)
            testCase.dataFolder = fullfile(fileparts(mfilename('fullpath')), 'test_data');
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
            % TODO Write the file reader
        end
    end
end