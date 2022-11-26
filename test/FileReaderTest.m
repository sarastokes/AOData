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

        function testAVI(testCase)
            reader = aod.util.readers.AviReader(...
                fullfile(testCase.dataFolder, 'test.avi'));
            out = reader.read();
            testCase.verifyEqual(size(out), [256, 256, 5]);
            testCase.verifyEqual(squeeze(out(1,1,:))', 0:0.25:1,...
                "RelTol", 0.01);
        end

        function testJSON(testCase)
            reader = aod.util.readers.JsonReader(...
                fullfile(testCase.dataFolder, 'test.json'));
            out = reader.read();
            testCase.verifyEqual(numel(fieldnames(out)), 4);
            testCase.verifyEqual(out.data, 1);
            testCase.verifyEqual(out.machine, '1P-PRIMATE');
        end
    end
end