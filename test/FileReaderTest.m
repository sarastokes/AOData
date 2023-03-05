classdef FileReaderTest < matlab.unittest.TestCase
% FILEREADERTEST
%
% Description:
%   Tests builtin support for reading files
%
% Parent:
%    matlab.unittest.TestCase
%
% Use:
%   result = runtests('FileReaderTest.m')
%
% See also:
%   runAODataTestSuite

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties
        dataFolder
    end

    methods (TestClassSetup)
        function methodSetup(testCase)
            testCase.dataFolder = fullfile(fileparts(mfilename('fullpath')), 'test_data');
            writematrix([8, 8.5, 7; 0 2.1 -1], ...
                fullfile(testCase.dataFolder, 'test.csv'));
        end
    end

    methods (TestMethodTeardown)
        function methodTeardown(testCase)
            writematrix([8, 8.5, 7; 0 2.1 -1], ...
                fullfile(testCase.dataFolder, 'test.csv'));
        end
    end

    methods (Test)
        function testCSV(testCase)
            reader = aod.util.readers.CsvReader(...
                fullfile(testCase.dataFolder, 'test.csv'));
            output = reader.readFile();
            testCase.verifyEqual(output, [8, 8.5, 7; 0 2.1 -1], ...
                'AbsTol', 0.001);

            % Change the data and test reload
            writematrix(-1*output, fullfile(testCase.dataFolder, 'test.csv'));
            reader.reload();
            testCase.verifyEqual(reader.Data, -1 * [8, 8.5, 7; 0 2.1 -1], ...
                'AbsTol', 0.001);
        end

        function testTXT(testCase)
            reader = test.TestTxtReader(...
                fullfile(testCase.dataFolder, 'test.txt'));
            testCase.verifyEqual(reader.Data.PMTGain, 0.541);
            testCase.verifyEqual(reader.Data.FieldOfView, [3.69 2.70]);
            testCase.verifyTrue(endsWith(reader.Data.Video, ...
                'AOData\test\test_data\test.avi'));
            testCase.verifyTrue(reader.Data.Stabilization);
            testCase.verifyTrue(reader.Data.ClosedLoop);
        end

        function testAVI(testCase)
            out = aod.util.readers.AviReader.read(...
                fullfile(testCase.dataFolder, 'test.avi'));
            testCase.verifyEqual(size(out), [256, 256, 5]);
            testCase.verifyEqual(squeeze(out(1,1,:))', 0:0.25:1,...
                "RelTol", 0.01);
        end

        function testJSON(testCase)
            out = aod.util.readers.JsonReader.read(...
                fullfile(testCase.dataFolder, 'test.json'));
            testCase.verifyEqual(numel(fieldnames(out)), 4);
            testCase.verifyEqual(out.data, 1);
            testCase.verifyEqual(out.machine, '1P-PRIMATE');
        end
    end
end