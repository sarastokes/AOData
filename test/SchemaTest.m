classdef SchemaTest < matlab.unittest.TestCase
% Tests schemas for AOData subclasses
%
% Description:
%   Tests the classes for schema management
%
% Superclass:
%    matlab.unittest.TestCase
%
% Use:
%   result = runtests('SchemaTest.m')
%
% See also:
%   runAODataTestSuite

% By Sara Patterson, 2023 (AOData)
% --------------------------------------------------------------------------

    methods (Test, TestTags="Entry")
        function Entry(testCase)
            obj = aod.schema.Entry([], 'Test', 'Number',...
                'Maximum', 3, 'Size', '(1,1)');
            [tf, ME] = obj.validate(3);
            testCase.verifyTrue(tf);
            testCase.verifyEmpty(ME);

            [tf, ME] = obj.validate(4, aod.infra.ErrorTypes.NONE);
            testCase.verifyFalse(tf);
            testCase.verifyNotEmpty(ME);
            if ~isempty(ME)  % avoid error cutting test short
                testCase.verifyNumElements(ME.cause, 1);
                testCase.verifyEqual(ME.identifier, 'validate:Failed');
                testCase.verifyEqual(ME.cause{1}.identifier, 'validate:MaximumExceeded');
            end

            testCase.verifyError(...
                @() obj.validate([4 4]), 'validate:Failed');
            [tf, ME] = obj.validate([4 4], aod.infra.ErrorTypes.NONE);
            testCase.verifyFalse(tf);
            testCase.verifyNotEmpty(ME);
            if ~isempty(ME)
                testCase.verifyNumElements(ME.cause, 2);
            end
        end
    end

    methods (Test, TestTags="DatasetCollection")
        function DatasetCollection(testCase)
            obj = aod.schema.DatasetCollection.populate('aod.core.Calibration');
            testCase.verifyNotEmpty(obj);

            testCase.verifyEqual(2, obj.Count);
            testCase.verifyEqual(["calibrationDate", "Target"], obj.Contents);

            testCase.verifyClass(obj.Entries(1).Parent, 'aod.schema.DatasetCollection');
        end
    end

    methods (Test, TestTags="FileCollection")
        function FileCollection(testCase)
            obj = aod.schema.FileCollection('aod.core.Calibration', []);
            testCase.verifyEmpty(obj);
            testCase.verifyEqual(obj.Count, 0);
            testCase.verifyEqual(obj.className, "aod.core.Calibration");

            obj.add('TestFile', 'Description', 'A test file', 'ExtensionType', '.txt');
            testCase.verifyNotEmpty(obj);
            testCase.verifyEqual(obj.Count, 1);
            testCase.verifyEqual(obj.Entries(1).Name, "TestFile");
            testCase.verifyEqual(obj.Contents, "TestFile");

            obj.remove('TestFile');
            testCase.verifyEmpty(obj);
            testCase.verifyEqual(obj.Count, 0);
            testCase.verifyEmpty(obj.Contents);

            % Make sure we can add back again without empty array error
            % Add in an unecessary "file" primitiveType specification as '
            % used for DatasetCollection and AttributeCollection to ensure
            % it doesn't throw an error
            obj.add('TestFile2', 'File', 'Description', 'A test file');
            testCase.verifyEqual(obj.Count, 1);
        end

        function FileCollectionErrors(testCase)
            obj = aod.schema.FileCollection('aod.core.Calibration', []);
            testCase.verifyError(...
                @() obj.add('Test', 'number', 'Description', 'Bad spec'),...
                "add:InvalidPrimitiveType");
        end
    end

    methods
        function IsPrimitiveType(testCase)
            obj = aod.schema.Entry([], 'Test', 'Number',...
                'Maximum', 3, 'Size', '(1,1)');
            testCase.verifyTrue(aod.schema.util.isPrimitiveType(obj, 'number'));
            testCase.verifyFalse(aod.schema.util.isPrimitiveType(obj, 'text'));

            testCase.verifyTrue(aod.schema.util.isPrimitiveType(obj.Primitive, 'number'));
            testCase.verifyFalse(aod.schema.util.isPrimitiveType(obj.Primitive, 'text'));
        end
    end
end