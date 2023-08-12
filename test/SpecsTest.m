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
            obj = aod.schema.specs.EntityType([], 'Calibration');
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
            obj = aod.schema.specs.EntityType([], []);
            testCase.verifyEmpty(obj);

            [tf, ME] = obj.validate(aod.core.Calibration("Test", getDateYMD()));
            testCase.confirmValid(tf, ME);
        end
    end

    methods (Test, TestTags="Enum")
        function Enum(testCase)
            obj = aod.schema.specs.Enum([], ["a", "b", "c"]);
            testCase.verifyFalse(obj.isempty());

            [tf, ME] = obj.validate("a");
            testCase.confirmValid(tf, ME);

            [tf, ME] = obj.validate("d");
            testCase.verifyFalse(tf);
            testCase.verifyEqual(ME.identifier, 'validate:InvalidEnum');
        end

        function EmptyEnum(testCase)
            obj = aod.schema.specs.Enum([], []);
            testCase.verifyEmpty(obj);
            testCase.verifyEqual(obj.text(), "[]");

            testCase.verifyTrue(obj.validate("d"));
        end
    end

    methods (Test, TestTags="Length")
        function Length(testCase)
            obj = aod.schema.specs.Length([], 3);
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
            obj = aod.schema.specs.Length([], []);
            testCase.verifyEmpty(obj);
            testCase.verifyEqual(obj.text(), "[]");

            [tf, ME] = obj.validate("d");
            testCase.confirmValid(tf, ME);
        end
    end

    methods (Test, TestTags="Count")
        function Count(testCase)
            obj = aod.schema.specs.Count([], 3);
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
            obj = aod.schema.specs.Count([], []);
            testCase.verifyEmpty(obj);
            testCase.verifyEqual(obj.text(), "[]");

            [tf, ME] = obj.validate("d");
            testCase.confirmValid(tf, ME);
        end
    end

    methods (Test, TestTags="Units")
        function Units(testCase)
            obj = aod.schema.specs.Units([], "mV");
            testCase.verifyFalse(obj.isempty());

            obj.setValue(["mV"; "sec"]);
            testCase.verifyEqual(obj.Value, ["mV", "sec"]);
        end

        function EmptyUnits(testCase)
            obj = aod.schema.specs.Units([], []);
            testCase.verifyEmpty(obj);
            testCase.verifyEqual(obj.text(), "[]");
        end
    end
end