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

    methods (Test, TestTags="Formats")
        function CSV(testCase)
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

        function TXT(testCase)
            reader = test.TestTxtReader(...
                fullfile(testCase.dataFolder, 'test.txt'));
            testCase.verifyEqual(reader.Data.PMTGain, 0.541);
            testCase.verifyEqual(reader.Data.FieldOfView, [3.69 2.70]);
            testCase.verifyTrue(endsWith(reader.Data.Video, ...
                'AOData\test\test_data\test.avi'));
            testCase.verifyTrue(reader.Data.Stabilization);
            testCase.verifyTrue(reader.Data.ClosedLoop);
        end

        function AVI(testCase)
            out = aod.util.readers.AviReader.read(...
                fullfile(testCase.dataFolder, 'test.avi'));
            testCase.verifyEqual(size(out), [256, 256, 5]);
            testCase.verifyEqual(squeeze(out(1,1,:))', 0:0.25:1,...
                "RelTol", 0.01);
        end

        function JSON(testCase)
            out = aod.util.readers.JsonReader.read(...
                fullfile(testCase.dataFolder, 'test.json'));
            testCase.verifyEqual(numel(fieldnames(out)), 4);
            testCase.verifyEqual(out.data, 1);
            testCase.verifyEqual(out.machine, '1P-PRIMATE');
        end

        function PNG(testCase)
            data = aod.util.readers.ImageReader.read(...
                fullfile(testCase.dataFolder, 'test.png'));
            testCase.verifyEqual(size(data), [360 242]);
        end
    end

    methods (Test, TestTags=["Formats", "Builtin"])
        function ImageJRois(testCase)
            % Circle ROIs
            out1 = aod.builtin.readers.ImageJRoiReader.read(...
                fullfile(testCase.dataFolder, 'RoiSet.zip'), [242, 360]);
            testCase.verifyEqual(numel(unique(out1)), 5);

            % Polygon ROIs
            out2 = aod.builtin.readers.ImageJRoiReader.read(...
                fullfile(testCase.dataFolder, 'Polygon_RoiSet.zip'), [242, 360]);
            testCase.verifyEqual(numel(unique(out2)), 4);
        end
    end

    methods (Test, TestTags="Local")
        function IconFolder(testCase)
            testCase.verifyEqual(...
                aod.app.util.getIconFolder(),...
                string(fullfile(getAOData(), 'src', '+aod', '+app', "+icons")) + filesep);
        end
    end
end