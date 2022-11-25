classdef FileReaderTest < matlab.unittest.TestCase
% FILEREADERTEST
%
% Description:
%   Tests modification of HDF5 files from persistent interface
%
% Parent:
%    matlab.unittest.TestCase
%
% Use:
%   result = runtests('FileReaderTest.m')
%
% See also:
%   runAODataTestSuite
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
        function testCSV(testCase)
            reader = aod.util.readers.CsvReader(...
                fullfile(testCase.dataFolder, 'test.csv'));
            out = reader.read();
            testCase.verifyEqual(out, [8, 8.5, 7; 0 2.1 -1]);
        end
    end
end