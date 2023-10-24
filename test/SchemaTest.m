classdef SchemaTest < matlab.unittest.TestCase
% Tests schemas for AOData subclasses
%
% Description:
%   Tests the primitives for dataset/attribute specification
%
% Superclass:
%    matlab.unittest.TestCase
%
% Use:
%   result = runtests('PrimitiveTest.m')
%
% See also:
%   runAODataTestSuite

% By Sara Patterson, 2023 (AOData)
% --------------------------------------------------------------------------

    methods (Test, TestTags="Entity")
        function Entity(testCase)
            obj = aod.schema.Entity([], 'Test', 'Number',...
                'Maximum', 3, 'Size', '(1,1)');
            [tf, ME] = obj.validate(3);
            testCase.verifyTrue(tf);
            testCase.verifyEmpty(ME);

            [tf, ME] = obj.validate(4);
            testCase.verifyFalse(tf);
            testCase.verifyNotEmpty(ME);
            if ~isempty(ME)  % avoid error cutting test short
                testCase.verifyNumElements(ME.cause, 1);
                testCase.verifyEqual(ME.identifier, 'validate:Failed');
                testCase.verifyEqual(ME.cause{1}.identifier, 'validate:MaximumExceeded');
            end

            [tf, ME] = obj.validate([4 4]);
            testCase.verifyFalse(tf);
            testCase.verifyNotEmpty(ME);
            if ~isempty(ME)
                testCase.verifyNumElements(ME.cause, 2);
            end
        end
    end
end