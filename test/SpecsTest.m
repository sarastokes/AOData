classdef SpecsTest < matlab.unittest.TestCase
% Tests schema primitives
%
% Parent:
%   matlab.unittest.TestCase

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    methods
        function confirmValid(testCase, tf, ME)
            testCase.verifyTrue(tf);
            testCase.verifyEmpty(ME);
        end
    end

    methods (Test, TestTags="EntityType")
        function EntityType(testCase)
            obj = aod.schema.validators.EntityType([], 'Calibration');
            testCase.verifyFalse(obj.isempty());

            [tf, ME] = obj.validate(aod.core.Calibration('Test', getDateYMD()));
            testCase.confirmValid(tf, ME);

            [tf, ME] = obj.validate([]);
            testCase.confirmValid(tf, ME);

            [tf, ME] = obj.validate(123);
            testCase.verifyFalse(tf);
            testCase.verifyEqual(ME.identifier, 'AOData:EntityType:Invalid');

            [tf, ME] = obj.validate(aod.core.Epoch(1));
            testCase.verifyFalse(tf);
            testCase.verifyEqual(ME.identifier, 'AOData:EntityType:Invalid');
        end

        function EmptyEntityType(testCase)
            obj = aod.schema.validators.EntityType([], []);
            testCase.verifyEmpty(obj);
            testCase.verifyEqual(obj.text(), "[]");
            testCase.verifyEqual(obj.jsonencode(), '[]');

            [tf, ME] = obj.validate(aod.core.Calibration("Test", getDateYMD()));
            testCase.confirmValid(tf, ME);
        end
    end

    methods (Test, TestTags="Enum")
        function Enum(testCase)
            obj = aod.schema.validators.Enum([], ["a", "b", "c"]);
            testCase.verifyFalse(obj.isempty());

            [tf, ME] = obj.validate("a");
            testCase.confirmValid(tf, ME);

            [tf, ME] = obj.validate("d");
            testCase.verifyFalse(tf);
            testCase.verifyEqual(ME.identifier, 'Enum:validate:InvalidEnum');
        end

        function EmptyEnum(testCase)
            obj = aod.schema.validators.Enum([], []);
            testCase.verifyEmpty(obj);
            testCase.verifyEqual(obj.text(), "[]");
            testCase.verifyEqual(obj.jsonencode(), '[]');

            testCase.verifyTrue(obj.validate("d"));
        end
    end

    methods (Test, TestTags="Length")
        function Length(testCase)
            obj = aod.schema.validators.Length([], 3);
            testCase.verifyFalse(obj.isempty());
            testCase.verifyEqual(obj.text(), "3");

            [tf, ME] = obj.validate("abc");
            testCase.confirmValid(tf, ME);

            [tf, ME] = obj.validate("a");
            testCase.verifyFalse(tf);
            testCase.verifyEqual(ME.identifier,...
                'validate:InvalidLength');
            [tf, ME] = obj.validate(123);
            testCase.verifyFalse(tf);
            testCase.verifyEqual(ME.identifier,...
                'validate:InvalidClass');
        end

        function EmptyLength(testCase)
            obj = aod.schema.validators.Length([], []);
            testCase.verifyEmpty(obj);
            testCase.verifyEqual(obj.text(), "[]");
            testCase.verifyEqual(obj.jsonencode(), '[]');

            [tf, ME] = obj.validate("d");
            testCase.confirmValid(tf, ME);

            obj.setValue(3);
            testCase.verifyNotEmpty(obj);
            testCase.verifyEqual(obj.Value, 3);
            testCase.verifyEqual(obj.text(), "3");

            obj.setValue([]);
            testCase.verifyEmpty(obj);
        end
    end

    methods (Test, TestTags="Count")
        function Count(testCase)
            obj = aod.schema.validators.Count([], 3);
            testCase.verifyFalse(isempty(obj));

            [tf, ME] = obj.validate(["a", "b", "c"]);
            testCase.confirmValid(tf, ME);

            [tf, ME] = obj.validate(["a", "b"]);
            testCase.verifyFalse(tf);
            testCase.verifyEqual(ME.identifier,...
                'validate:InvalidCount');

            [tf, ME] = obj.validate([]);
            testCase.confirmValid(tf, ME);
        end

        function EmptyCount(testCase)
            obj = aod.schema.validators.Count([], []);
            testCase.verifyEmpty(obj);
            testCase.verifyEqual(obj.text(), "[]");
            testCase.verifyEqual(obj.jsonencode(), '[]');

            [tf, ME] = obj.validate("d");
            testCase.confirmValid(tf, ME);

            obj.setValue(3);
            testCase.verifyNotEmpty(obj);
            testCase.verifyEqual(obj.text(), "3");

            obj.setValue([]);
            testCase.verifyEmpty(obj);
        end
    end

    methods (Test, TestTags="Units")
        function Units(testCase)
            obj = aod.schema.decorators.Units([], "mV");
            testCase.verifyFalse(obj.isempty());

            obj.setValue(["mV"; "sec"]);
            testCase.verifyEqual(obj.Value, ["mV", "sec"]);
        end

        function EmptyUnits(testCase)
            obj = aod.schema.decorators.Units([], []);
            testCase.verifyEmpty(obj);
            testCase.verifyEqual(obj.text(), "[]");
            testCase.verifyEqual(obj.jsonencode(), '[]');

            obj.setValue("mV");
            testCase.verifyNotEmpty(obj);
            testCase.verifyEqual(obj.Value, "mV");
            testCase.verifyEqual(obj.text(), string('"mV"'));

            obj.setValue([]);
            testCase.verifyEmpty(obj);
        end
    end

    methods (Test, TestTags="ExtensionType")
        function ExtensionType(testCase)

            obj = aod.schema.validators.ExtensionType([], ".txt");
            testCase.verifyNotEmpty(obj);

            [tf, ME] = obj.validate([]);
            testCase.confirmValid(tf, ME);

            [tf, ME] = obj.validate("test.txt");
            testCase.confirmValid(tf, ME);

            [tf, ME] = obj.validate("test.csv");
            testCase.verifyFalse(tf);
            testCase.verifyEqual(ME.identifier, 'validate:InvalidExtension');

            [tf, ME] = obj.validate("test");
            testCase.verifyFalse(tf);
            testCase.verifyEqual(ME.identifier, 'validate:NoExtensionFound');
        end

        function ExtensionTypeEmpty(testCase)
            obj = aod.schema.validators.ExtensionType([], []);
            testCase.verifyEmpty(obj);
            testCase.verifyEqual(obj.text(), "[]");
            testCase.verifyEqual(obj.jsonencode(), '[]');

            [tf, ME] = obj.validate("test.txt");
            testCase.confirmValid(tf, ME);

            obj.setValue(".txt");
            testCase.verifyNotEmpty(obj);

            obj.setValue("");
            testCase.verifyEmpty(obj);

        end

        function ExtensionTypeErrors(testCase)
            testCase.verifyError(...
                @() aod.schema.validators.ExtensionType([], [".txt", "csv"]),...
                "setExtensionType:InvalidExtensionFormat");

            testCase.verifyError(...
                @() aod.schema.validators.ExtensionType([], [".txt", "csv"; ".dat", ".json"]),...
                "setExtensionType:InvalidSize");

            testCase.verifyError(...
                @() aod.schema.validators.ExtensionType([], ["", ".json"]),...
                "setExtensionType:SomeValuesEmpty");
        end
    end

    methods (Test, TestTags="Minimum")
        function Minimum(testCase)
            obj = aod.schema.validators.Minimum([], 0);
            testCase.verifyNotEmpty(obj);

            [tf, ME] = obj.validate([]);
            testCase.confirmValid(tf, ME);

            [tf, ME] = obj.validate(1);
            testCase.confirmValid(tf, ME);

            [tf, ME] = obj.validate(-1);
            testCase.verifyFalse(tf);
            testCase.verifyEqual(ME.identifier, 'validate:MinimumExceeded');
        end

        function MinimumEquality(testCase)
            obj = aod.schema.validators.Minimum([], 0);
            testCase.verifyEqual(obj, aod.schema.validators.Minimum([], 0));
            testCase.verifyNotEqual(obj, aod.schema.validators.Minimum([], 1));
        end

        function MinimumEmpty(testCase)
            obj = aod.schema.validators.Minimum([], []);
            testCase.verifyEmpty(obj);
            testCase.verifyEqual(obj.text(), "[]");
            testCase.verifyEqual(obj.jsonencode(), '[]');

            [tf, ME] = obj.validate(1);
            testCase.confirmValid(tf, ME);

            obj.setValue(1);
            testCase.verifyNotEmpty(obj);
            testCase.verifyEqual(obj.text(), "1");

            obj.setValue([]);
            testCase.verifyEmpty(obj);

            obj.setValue("[]");
            testCase.verifyEmpty(obj);
        end
    end

    methods (Test, TestTags="Maximum")
        function Maximum(testCase)
            obj = aod.schema.validators.Maximum([], 3);
            testCase.verifyNotEmpty(obj);

            [tf, ME] = obj.validate([]);
            testCase.confirmValid(tf, ME);

            [tf, ME] = obj.validate(1);
            testCase.confirmValid(tf, ME);

            [tf, ME] = obj.validate(4);
            testCase.verifyFalse(tf);
            testCase.verifyEqual(ME.identifier, 'validate:MaximumExceeded');
        end

        function MaximumEquality(testCase)
            obj = aod.schema.validators.Maximum([], 0);
            testCase.verifyEqual(obj, aod.schema.validators.Maximum([], 0));
            testCase.verifyNotEqual(obj, aod.schema.validators.Maximum([], 1));
            testCase.verifyNotEqual(obj, aod.schema.validators.Minimum([], 0));
        end

        function MaximumEmpty(testCase)
            obj = aod.schema.validators.Maximum([], []);
            testCase.verifyEmpty(obj);
            testCase.verifyEqual(obj.text(), "[]");
            testCase.verifyEqual(obj.jsonencode(), '[]');

            [tf, ME] = obj.validate(1);
            testCase.confirmValid(tf, ME);

            obj.setValue(1);
            testCase.verifyNotEmpty(obj);
            testCase.verifyEqual(obj.text(), "1");

            obj.setValue([]);
            testCase.verifyEmpty(obj);

            obj.setValue("[]");
            testCase.verifyEmpty(obj);
        end
    end
end