classdef PrimitiveTest < matlab.unittest.TestCase
% Tests primitives for AOData schemas
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

    methods (Test, TestTags="Integer")
        function Integer(testCase)
            obj = aod.schema.primitives.Integer("Test");
            testCase.verifyEqual(obj.Name, "Test");

            testCase.verifyEmpty(obj.Units);
            obj.assign("Units", "mV");
            testCase.verifyEqual(obj.Units.Value, "mV");

            testCase.verifyEmpty(obj.Description);
            obj.assign('Description', "Test");
            testCase.verifyEqual(obj.Description.Value, "Test");

            testCase.verifyEmpty(obj.Size);
            obj.setSize("(1,2)");
            testCase.verifyEqual(obj.Size.text(), "(1,2)");

            testCase.verifyEmpty(obj.Default);
            obj.assign('Default', [1,2]);
            testCase.verifyEqual(obj.Default.Value, [1,2]);

            testCase.verifyEmpty(obj.Format);
            testCase.verifyEmpty(obj.Minimum);
            testCase.verifyEmpty(obj.Maximum);
            testCase.verifyClass(obj.Default.Value, "double");

            obj.assign('Format', 'uint8');
            testCase.verifyEqual(obj.Format.Value, "uint8");
            testCase.verifyEqual(obj.Minimum.Value, uint8(0));
            testCase.verifyEqual(obj.Maximum.Value, uint8(255));
            testCase.verifyClass(obj.Default.Value, "uint8");

            obj.assign("Minimum", 1);
            testCase.verifyEqual(obj.Minimum.Value, uint8(1));

            % TODO: Implement wrapper class
            obj.assign("Format", "double");
            testCase.verifyEqual(obj.Minimum.Value, 1);
            testCase.verifyEmpty(obj.Maximum.Value);
        end

        function IntegerErrors(testCase)
            obj = aod.schema.primitives.Integer("Test");
            testCase.verifyError(...
                @() obj.assign('Size', "(1,2)", 'Default', 2),...
                "checkIntegrity:InvalidDefault");
        end
    end

    methods (Test, TestTags="Number")
        function Number(testCase)
            obj = aod.schema.primitives.Number("Test");
            testCase.verifyEqual(obj.Format.Value, "double");

            obj.assign('Minimum', 1, 'Maximum', 3);
            testCase.verifyEqual(obj.Minimum.Value, 1);
            testCase.verifyEqual(obj.Minimum.Value, 3);

            testCase.verifyTrue(obj.validate(2));

        end
    end

    methods (Test, TestTags="Link")
        function Link(testCase)
            obj = aod.schema.primitives.Link("Test");

            testCase.verifyEmpty(obj.EntityType);
            testCase.verifyEmpty(obj.Format);
            obj.assign('EntityType', 'epoch');
            testCase.verifyEqual(obj.EntityType.Value, aod.common.EntityTypes.EPOCH);
            testCase.verifyEqual(obj.Format.Value, ["aod.core.Epoch", "aod.persistent.Epoch"]);

            testCase.verifyError(...
                @() obj.assign('Default'), 'MATLAB:InputParser:ParamMissingValue');
            testCase.verifyError(...
                @() obj.assign('Default', 1), "assign:InvalidParameter");
        end
    end
end