classdef HDFTest < matlab.unittest.TestCase
% HDFTEST
%
% Description:
%   Tests MATLAB datatype I/O to HDF5
%
% Parent:
%    matlab.unittest.TestCase
%
% Use:
%   result = runtests('HDFTest.m')
%
% See also:
%   runAODataTestSuite
% -------------------------------------------------------------------------

    properties
        HDF_FILE = [fullfile(getpref('AOData', 'BasePackage'),...
            filesep, 'test', filesep, 'HdfTest.h5')];
    end

    methods (TestClassSetup)
        function hdfSetup(testCase)
            aod.h5.HDF5.createFile(testCase.HDF_FILE, true)
        end
    end

    methods (TestClassTeardown)
        function methodTeardown(testCase) %#ok<MANU> 
            %if exist(testCase.HDF_FILE, 'file')
            %    delete(testCase.HDF_FILE);
            %end
        end
    end

    methods (Test, TestTags={'Dataset'})
        function testString(testCase)
            inputString = "abc";
            aod.h5.writeDatasetByType(testCase.HDF_FILE, '/', 'String', inputString);
            outputString = aod.h5.readDatasetByType(testCase.HDF_FILE, '/', 'String');
            testCase.verifyEqual(inputString, outputString);
        end

        function testStringArray(testCase)
            inputString = ["abc", "def", "ghi"];
            aod.h5.writeDatasetByType(testCase.HDF_FILE, '/', 'StringArray', inputString);
            outputString = aod.h5.readDatasetByType(testCase.HDF_FILE, '/', 'StringArray');
            testCase.verifyEqual(inputString, outputString);
        end

        function testChar(testCase)
            inputChar = 'abcdefghi';
            aod.h5.writeDatasetByType(testCase.HDF_FILE, '/', 'Char', inputChar);
            outputChar = aod.h5.readDatasetByType(testCase.HDF_FILE, '/', 'Char');
            testCase.verifyEqual(inputChar, outputChar);
        end

        function testDouble(testCase)
            inputDouble = [1.5 2.5 3.5; 4.2 3.2 1.2];
            aod.h5.writeDatasetByType(testCase.HDF_FILE, '/', 'Double', inputDouble);
            outputDouble = aod.h5.readDatasetByType(testCase.HDF_FILE, '/', 'Double');
            testCase.verifyEqual(inputDouble, outputDouble);
        end

        function testLogical(testCase)
            inputLogical = true;
            aod.h5.writeDatasetByType(testCase.HDF_FILE, '/', 'Logical', inputLogical);
            outputLogical = aod.h5.readDatasetByType(testCase.HDF_FILE, '/', 'Logical');
            testCase.verifyEqual(inputLogical, outputLogical);
        end

        function testEnum(testCase)
            inputEnum = test.TestEnumType.TYPEONE;
            aod.h5.writeDatasetByType(testCase.HDF_FILE, '/', 'enum', inputEnum);
            outputEnum = aod.h5.readDatasetByType(testCase.HDF_FILE, '/', 'enum');
            testCase.verifyEqual(outputEnum, test.TestEnumType.TYPEONE);
        end

        function testTable(testCase)
            inputTable = table(rangeCol(1,4), {'a'; 'b'; 'c'; 'd'}, ["a", "b", "c", "d"]',...
                'VariableNames', {'Numbers', 'Characters', 'Strings'});
            aod.h5.writeDatasetByType(testCase.HDF_FILE, '/', 'Table', inputTable);
            outputTable = aod.h5.readDatasetByType(testCase.HDF_FILE, '/', 'Table');
            testCase.verifyEqual(inputTable, outputTable);
        end

        function testDuration(testCase)
            inputDuration = seconds(1:5);
            aod.h5.writeDatasetByType(testCase.HDF_FILE, '/', 'Duration', inputDuration);
            outputDuration = aod.h5.readDatasetByType(testCase.HDF_FILE, '/', 'Duration');
            testCase.verifyEqual(inputDuration, outputDuration);
        end

        % MATLAB-specific data types
        function testAffine2d(testCase)
            inputAffine2d = affine2d(eye(3));
            aod.h5.writeDatasetByType(testCase.HDF_FILE, '/', 'affine2d', inputAffine2d);
            outputAffine2d = aod.h5.readDatasetByType(testCase.HDF_FILE, '/', 'affine2d');
            testCase.verifyEqual(inputAffine2d, outputAffine2d);
        end

        function testSimtform2d(testCase)
            inputTform = simtform2d(3, 30, [10 20.5]);
            aod.h5.writeDatasetByType(testCase.HDF_FILE, '/', 'simtform2d', inputTform);
            outputTform = aod.h5.readDatasetByType(testCase.HDF_FILE, '/', 'simtform2d');
            testCase.verifyEqual(inputTform, outputTform);
        end

        function testImref2d(testCase)
            inputRefObj = imref2d([242 360]);
            aod.h5.writeDatasetByType(testCase.HDF_FILE, '/', 'imref2d', inputRefObj);
            outputRefObj = aod.h5.readDatasetByType(testCase.HDF_FILE, '/', 'imref2d');
            testCase.verifyEqual(inputRefObj, outputRefObj);
        end
    end

    methods (Test, TestTags={'Attributes'})
        function testLogicalAtt(testCase)
            aod.h5.HDF5.writeatts(testCase.HDF_FILE, '/', 'Logical_True', true);
            output = aod.h5.readAttributeByType(testCase.HDF_FILE, '/', 'Logical_True'); 
            testCase.verifyEqual(output, true);
        end

        function testEnumAtt(testCase)
            input = aod.core.EntityTypes.EXPERIMENT;
            aod.h5.HDF5.writeatts(testCase.HDF_FILE, '/', 'Enum', input);
            output = aod.h5.readAttributeByType(testCase.HDF_FILE, '/', 'Enum');
            testCase.verifyEqual(input, output);
        end
    end
end 