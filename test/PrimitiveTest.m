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

    methods (Test, TestTags="Primitive")
        function PrimitiveErrors(testCase)
            testCase.verifyError(...
                @() aod.schema.primitives.Boolean("123", []),...
                "setName:InvalidName");
        end
    end

    methods (Test, TestTags="Text")
        function Text(testCase)
            obj = aod.schema.primitives.Text("Test", []);
            testCase.verifyFalse(obj.Required);

            testCase.verifyFalse(obj.Description.isSpecified());
            obj.assign('Description', 'This is my test description');
            testCase.verifyTrue(obj.Description.isSpecified());
        end

        function TextWithOptions(testCase)
            obj = aod.schema.primitives.Text("Test", [],...
                "Enum", ["a", "b", "c"], "Length", 1, "Default", "b");
            testCase.verifyError(...
                @()obj.validate("d"), 'validate:SchemaViolationsDetected');
        end
    end

    methods (Test, TestTags="Duration")
        function Duration(testCase)
            obj = aod.schema.primitives.Duration("Test", []);

            obj.assign("Format", "s");
            testCase.verifyEqual(obj.Format.Value, "s");
            testCase.verifyTrue(obj.validate(seconds(1)));
            obj.assign('Default', seconds(1));
        end

        function DurationWithOptions(testCase)
            obj = aod.schema.primitives.Duration("Test", [],...
                "Size", "(1,1)", "Format", "s", "Default", seconds(1));
            testCase.verifyTrue(obj.validate(seconds(2)));
            testCase.verifyFalse(obj.validate(seconds(1:3), aod.infra.ErrorTypes.NONE));
        end

        function DurationErrors(testCase)
            obj = aod.schema.primitives.Duration("Test", []);
            testCase.verifyError(...
                @() obj.assign('Format', 'badinput'),...
                'setFormat:InvalidFormatForDuration');

            obj.assign("Format", "s");
            testCase.verifyError(...
                @() obj.validate(minutes(1)), 'validate:SchemaViolationsDetected');
            testCase.verifyError( ...
                @()obj.assign('Default', minutes(1)), ...
                'checkIntegrity:SchemaConflictsDetected');
            obj.assign('Default', seconds(1));
            testCase.verifyError(...
                @() obj.assign("Format", "minutes"),...
                'checkIntegrity:SchemaConflictsDetected');
        end
    end

    methods (Test, TestTags="Boolean")
        function Boolean(testCase)
            obj = aod.schema.primitives.Boolean("Test", []);

            % Some tests for the "Required" option
            testCase.verifyTrue(ismember("Required", obj.getOptions));
            testCase.verifyFalse(obj.Required);
            obj.setRequired(true);
            testCase.verifyTrue(obj.Required);
            obj.assign('Required', false);
            testCase.verifyFalse(obj.Required);

            % Back to testing the rest of the class
            obj.assign('Size', '(1,1)');
            testCase.verifyTrue(obj.validate(true));
            testCase.verifyFalse(obj.validate([true, true], aod.infra.ErrorTypes.NONE));
        end

        function BooleanWithOptions(testCase)
            obj = aod.schema.primitives.Boolean("Test", [],...
                "Default", false, "Required", true);
            testCase.verifyError(...
                @() obj.setSize("(1,2)"),...
                'checkIntegrity:SchemaConflictsDetected');
        end
    end

    methods (Test, TestTags="Integer")
        function Integer(testCase)
            obj = aod.schema.primitives.Integer("Test", []);
            testCase.verifyEqual(obj.Name, "Test");

            testCase.verifyFalse(obj.Units.isSpecified());
            obj.assign("Units", "mV");
            testCase.verifyEqual(obj.Units.Value, "mV");

            testCase.verifyFalse(obj.Description.isSpecified());
            obj.assign('Description', "Test");
            testCase.verifyEqual(obj.Description.Value, "Test");

            testCase.verifyFalse(obj.Size.isSpecified());
            obj.setSize("(1,2)");
            testCase.verifyEqual(obj.Size.text(), "(1,2)");

            testCase.verifyFalse(obj.Default.isSpecified());
            obj.assign('Default', [1,2]);
            testCase.verifyEqual(obj.Default.Value, [1,2]);

            testCase.verifyFalse(obj.Class.isSpecified());
            testCase.verifyFalse(obj.Minimum.isSpecified());
            testCase.verifyFalse(obj.Maximum.isSpecified());
            testCase.verifyClass(obj.Default.Value, "double");

            obj.assign('Class', 'uint8');
            testCase.verifyEqual(obj.Class.Value, "uint8");
            testCase.verifyEqual(obj.Minimum.Value, uint8(0));
            testCase.verifyEqual(obj.Maximum.Value, uint8(255));
            testCase.verifyClass(obj.Default.Value, "uint8");

            obj.assign("Minimum", 1);
            testCase.verifyEqual(obj.Minimum.Value, uint8(1));

            % TODO: Implement wrapper class
            testCase.verifyError(...
                @() obj.assign("Class", "string"),...
                "setClass:InvalidFormat");
        end

        function IntegerDouble(testCase)
            obj = aod.schema.primitives.Integer("Test", [],...
                "Class", "double");
            testCase.verifyEqual(obj.Minimum.Value, 0);
            testCase.verifyFalse(obj.Maximum.isSpecified());
            testCase.verifyTrue(obj.validate(1));
            testCase.verifyError(...
                @() obj.validate(1.5), 'validate:SchemaViolationsDetected');

            obj = aod.schema.primitives.Integer("Test", [],...
                "Minimum", 2);
            obj.assign("Class", "double");
            testCase.verifyEqual(obj.Minimum.Value, 2);
        end

        function IntegerErrors(testCase)
            obj = aod.schema.primitives.Integer("Test", []);
            testCase.verifyError(...
                @() obj.assign('Size', "(1,2)", 'Default', 2),...
                'checkIntegrity:SchemaConflictsDetected');
        end
    end

    methods (Test, TestTags="Number")
        function Number(testCase)
            obj = aod.schema.primitives.Number("Test", []);
            testCase.verifyEqual(obj.Class.Value, "double");

            obj.assign('Minimum', 1, 'Maximum', 3);
            testCase.verifyEqual(obj.Minimum.Value, 1);
            testCase.verifyEqual(obj.Maximum.Value, 3);

            testCase.verifyTrue(obj.validate(2));
        end
    end

    methods (Test, TestTags="Link")
        function Link(testCase)
            obj = aod.schema.primitives.Link("Test", []);

            testCase.verifyFalse(obj.EntityType.isSpecified());
            testCase.verifyFalse(obj.Class.isSpecified());
            obj.assign('EntityType', 'epoch');
            testCase.verifyEqual(obj.EntityType.Value, aod.common.EntityTypes.EPOCH);
            testCase.verifyEqual(obj.Class.Value, ["aod.core.Epoch", "aod.persistent.Epoch"]);

            testCase.verifyError(...
                @() obj.assign('Default'), 'MATLAB:InputParser:ParamMissingValue');
            testCase.verifyError(...
                @() obj.assign('Default', 1), "assign:InvalidParameter");
        end
    end

    methods (Test, TestTags="File")
        function File(testCase)
            obj = aod.schema.primitives.File("Test", []);
            testCase.verifyFalse(obj.Extension.isSpecified());

            obj = aod.schema.primitives.File("Test", [], "Extension", ".csv");
            testCase.verifyEqual(obj.Extension.Value, ".csv");

            testCase.verifyError(@() obj.assign('Default', 1), 'checkIntegrity:SchemaConflictsDetected');
            testCase.verifyError(@() obj.assign('Format', 'char'), 'assign:InvalidParameter');
        end

        function File2(testCase)
            obj = aod.schema.primitives.File("Test", []);

            testCase.verifyTrue(obj.validate("myfile.csv"));
            obj.assign('Extension', [".json", ".txt"]);
            testCase.verifyTrue(obj.validate("myfile.json"));
            testCase.verifyError(...
                @() obj.validate("myfile.csv"),...
                'validate:SchemaViolationsDetected');

        end

        function FileWithOptions(testCase)
            obj = aod.schema.primitives.File("Test", [],...
                "Default", "myfile.json", "Required", true,...
                "Description", "this is a test");

            testCase.verifyError(...
                @() obj.assign('Extension', '.csv'),...
                "checkIntegrity:SchemaConflictsDetected");
            obj.assign("Extension", ".json");
            obj.assign("Default", []);
        end
    end
end