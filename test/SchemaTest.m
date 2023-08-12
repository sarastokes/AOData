classdef SchemaTest < matlab.unittest.TestCase
% Tests schemas for AOData subclasses
%
% Description:
%   Tests the individual components for schema creation and management
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

    methods (Test, TestTags="Integer")
        function Integer(testCase)
            obj = aod.specification.types.Integer("Test");
            testCase.verifyEqual(obj.Name, "Test");

            testCase.verifyEmpty(obj.Units);
            obj.assign("Units", "mV");
            testCase.verifyEqual(obj.Units, "mV");

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

            obj.assign("Format", "double");
            testCase.verifyEqual(obj.Minimum.Value, 1);
            testCase.verifyEmpty(obj.Maximum.Value);
        end

        function IntegerErrors(testCase)
            testCase.verifyError(...
                @() obj.assign('Size', "(1,2)", 'Default', 2),...
                "checkIntegrity:InvalidDefault");
        end
    end

    methods (Test, TestTags="Number")
        function Number(testCase)
            obj = aod.specification.types.Number("Test");
            
            testCase.verifyEqual(obj.Format, "double");
        end
    end

    methods (Test, TestTags="Link")
        function Link(testCase)
            obj = aod.specification.types.Link("Test");

            testCase.verifyEmpty(obj.EntityType);
            testCase.verifyEmpty(obj.Format);
            obj.assign('EntityType', 'epoch');
            testCase.verifyEqual(obj.entityType, aod.common.EntityTypes.EPOCH);
            testCase.verifyEqual(obj.Format, ["aod.core.Epoch", "aod.persistent.Epoch"]);

            testCase.verifyError(...
                @() obj.assign('Default'), "assign:InvalidParameter");
        end
    end
end