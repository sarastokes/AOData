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

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties
        FOLDER
        FILE
    end

    methods (TestClassSetup)
        function methodSetup(testCase)
            testCase.FOLDER = fullfile(fileparts(mfilename('fullpath')), 'test_data');
            writematrix([8, 8.5, 7; 0 2.1 -1], ...
                fullfile(testCase.FOLDER, 'test.csv'));

            testCase.FILE = fullfile(test.util.getAODataTestFolder(), 'FileReaderTest.h5');
            h5tools.createFile(testCase.FILE, true);

        end
    end

    methods (TestMethodTeardown)
        function methodTeardown(testCase)
            writematrix([8, 8.5, 7; 0 2.1 -1], ...
                fullfile(testCase.FOLDER, 'test.csv'));
        end
    end

    methods (Test, TestTags="Formats")
        function CSV(testCase)
            reader = aod.util.readers.CsvReader(fullfile(testCase.FOLDER, 'test.csv'));
            output = aod.util.readers.CsvReader.read(...
                fullfile(testCase.FOLDER, 'test.csv'));
            testCase.verifyEqual(output, [8, 8.5, 7; 0 2.1 -1], ...
                'AbsTol', 0.001);

            % Change the data and test reload
            writematrix(-1*output, fullfile(testCase.FOLDER, 'test.csv'));
            output = reader.reload();
            testCase.verifyEqual(output, -1 * [8, 8.5, 7; 0 2.1 -1], ...
                'AbsTol', 0.001);
        end

        function MAT(testCase)
            reader = aod.util.readers.MatReader(...
                fullfile(testCase.FOLDER, 'test.mat'));
            output = reader.readFile();
            testCase.verifyEqual(output, eye(3));

            testCase.verifyEqual(aod.util.readers.MatReader.read(...
                fullfile(testCase.FOLDER, 'test.mat')), eye(3));
        end

        function TXT(testCase)
            reader = test.TestTxtReader(...
                fullfile(testCase.FOLDER, 'test.txt'));
            testCase.verifyEqual(reader.Data.PMTGain, 0.541);
            testCase.verifyEqual(reader.Data.FieldOfView, [3.69 2.70]);
            testCase.verifyTrue(endsWith(reader.Data.Video, ...
                'AOData\test\test_data\test.avi'));
            testCase.verifyTrue(reader.Data.Stabilization);
            testCase.verifyTrue(reader.Data.ClosedLoop);
            
            reader.changeFile(fullfile(testCase.FOLDER, 'test.txt'));
        end

        function AVI(testCase)
            out = aod.util.readers.AviReader.read(...
                fullfile(testCase.FOLDER, 'test.avi'));
            testCase.verifyEqual(size(out), [256, 256, 5]);
            testCase.verifyEqual(squeeze(out(1,1,:))', 0:0.25:1,...
                "RelTol", 0.01);
        end

        function JSON(testCase)
            out = aod.util.readers.JsonReader.read(...
                fullfile(testCase.FOLDER, 'test.json'));
            testCase.verifyEqual(numel(fieldnames(out)), 4);
            testCase.verifyEqual(out.data, 1);
            testCase.verifyEqual(out.machine, '1P-PRIMATE');
        end

        function PNG(testCase)
            data = aod.util.readers.ImageReader.read(...
                fullfile(testCase.FOLDER, 'test.png'));
            testCase.verifyEqual(size(data), [360 242]);

            reader = aod.util.readers.ImageReader(...
                fullfile(testCase.FOLDER, 'test.png'));
            aod.h5.write(testCase.FILE, '/', 'PngReader', reader);
        end
    end

    methods (Test, TestTags="Builtin")
        function ImageJRois(testCase)
            % Circle ROIs
            out1 = aod.builtin.readers.ImageJRoiReader.read(...
                fullfile(testCase.FOLDER, 'RoiSet.zip'), [242, 360]);
            testCase.verifyEqual(numel(unique(out1)), 5);

            % Polygon ROIs
            reader = aod.builtin.readers.ImageJRoiReader(...
                fullfile(testCase.FOLDER, 'Polygon_RoiSet.zip'), [242, 360]);
            out2 = reader.readFile();
            testCase.verifyEqual(numel(unique(out2)), 4);

            aod.h5.write(testCase.FILE, '/', 'ImageJRoiReader', reader);
            reader2 = aod.h5.read(testCase.FILE, '/', 'ImageJRoiReader');
            testCase.verifyEqual(numel(unique(reader2.readFile())), 4);

            reader.changeFile(fullfile(testCase.FOLDER, 'RoiSet.zip'));
            testCase.verifyFalse(contains(reader.fullFile, 'Polygon'));
        end

        function RegistrationReportReader(testCase)
            out = aod.builtin.readers.RegistrationReportReader.read(...
                fullfile(testCase.FOLDER, '851_20230314_ref_0003_20230314_motion_ref000_001.csv'));
            testCase.verifyTrue(out.hasFrame);
            testCase.verifySize(out.stripX, [3020 20]);
            testCase.verifySize(out.frameXY, [3020 2]);
            testCase.verifyClass(out.regDescription, 'string');
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