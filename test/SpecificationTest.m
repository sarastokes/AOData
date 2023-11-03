classdef SpecificationTest < matlab.unittest.TestCase
% Tests specification of AOData subclasses
%
% Description:
%   Tests validator, descriptor and default specifications
%
% Superclass:
%    matlab.unittest.TestCase
%
% Use:
%   result = runtests('SpecificationTest.m')
%
% See also:
%   runAODataTestSuite

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

%#ok<*MANU,*NASGU,*ASGLU>

    methods
        function confirmValid(testCase, tf, ME)
            testCase.verifyTrue(tf);
            testCase.verifyEmpty(ME);
        end
    end

    methods (Test, TestTags="Size")
        function EmptySize(testCase)
            emptyObj = aod.schema.validators.Size([], []);
            testCase.verifyFalse(emptyObj.isSpecified());
            testCase.verifyEqual(emptyObj.text(), "[]");
            testCase.verifyTrue(emptyObj.validate(123));
        end

        function SizeEquality(testCase)
            obj1 = aod.schema.validators.Size([], []);
            obj2 = aod.schema.validators.Size([], "(1,:)");
            obj3 = aod.schema.validators.Size([], "(1,2)");
            obj4 = aod.schema.validators.Size([], "(2,1)");
            obj5 = aod.schema.validators.Size([], "(2,2,2)");

            testCase.verifyNotEqual(obj1, 123);
            testCase.verifyNotEqual(obj1, obj2);
            testCase.verifyNotEqual(obj2, obj3);
            testCase.verifyNotEqual(obj3, obj4);
            testCase.verifyNotEqual(obj4, obj5);
        end

        function SizeComparison(testCase)
            import aod.schema.MatchType

            refObj1 = aod.schema.validators.Size([], "(1,1)");
            refObj2 = aod.schema.validators.Size([], []);

            testCase.verifyEqual(MatchType.CHANGED,...
                refObj1.compare(aod.schema.validators.Size([], "(1,:)")));
            testCase.verifyEqual(MatchType.SAME,...
                refObj1.compare(refObj1));
            testCase.verifyEqual(MatchType.REMOVED,...
                refObj1.compare(refObj2));
            testCase.verifyEqual(MatchType.ADDED,...
                refObj2.compare(refObj1));

            testCase.verifyError(...
                @() refObj1.compare(aod.schema.validators.Class([], "string")),...
                "compare:UnlikeSpecificationTypes");
        end

        function SizeErrors(testCase)
            testCase.verifyError(...
                @() aod.schema.validators.Size([], "(1)"),...
                "Size:InvalidDimensions");
        end

        function FixedDimensions(testCase)
            ref1 = [aod.schema.validators.size.FixedDimension([], 1),...
                   aod.schema.validators.size.FixedDimension([], 2)];
            testCase.verifyNotEqual(ref1(1), ref1(2));
            testCase.verifyEqual(ref1(1), ref1(1));

            rowSize1a = aod.schema.validators.Size([], "(1,2)");
            testCase.verifyEqual(rowSize1a.text(), "(1,2)");
            testCase.verifyEqual(rowSize1a.Value(1), ref1(1));
            testCase.verifyEqual(rowSize1a.Value(2), ref1(2));

            rowSize1b = aod.schema.validators.Size([], "(1,2)");
            testCase.verifyClass(rowSize1b.Value, ...
                "aod.schema.validators.size.FixedDimension");
            testCase.verifyTrue(rowSize1b.validate([1 2]));
            testCase.verifyFalse(rowSize1b.validate([1 2]'));
            testCase.verifyEqual(rowSize1a, rowSize1b);

            ref1(1).setValue(2);
            testCase.verifyEqual(ref1(1).Length, 2);
            testCase.verifyTrue(ref1(1).validate('2'));
        end

        function MixedDimensions(testCase)
            ref2 = [aod.schema.validators.size.UnrestrictedDimension([]),...
                    aod.schema.validators.size.FixedDimension([], 1)];

            rowSize2a = aod.schema.validators.Size([], "(:,1)");
            testCase.verifyEqual(rowSize2a.text(), "(:,1)");
            testCase.verifyEqual(rowSize2a.Value, ref2);
        end

        function UnrestrictedDimensions(testCase)
            ref3 = [aod.schema.validators.size.UnrestrictedDimension([]),...
                    aod.schema.validators.size.UnrestrictedDimension([])];

            rowSize3a = aod.schema.validators.Size([], "(:,:)");
            testCase.verifyEqual(rowSize3a.text(), "(:,:)");

            testCase.verifyEqual(rowSize3a.Value, ref3);
            testCase.verifyTrue(rowSize3a.validate(eye(3)));
            testCase.verifyFalse(rowSize3a.validate(ones(3,3,3)));
        end
    end

    methods (Test, TestTags="MatlabClass")
        function MatlabClass(testCase)
            obj1 = aod.schema.validators.Class([], 'char');
            testCase.verifyTrue(obj1.validate('test'));

            expt = aod.core.Experiment('test', cd, getDateYMD());
            obj2 = aod.schema.validators.Class([], findprop(expt, 'epochIDs'));
            testCase.verifyEqual(obj2.Value, "double");
            testCase.verifyTrue(obj2.validate(123));
            testCase.verifyFalse(obj2.validate('test'));

            testCase.verifyNotEqual(obj1, obj2);
        end

        function MultipleMatlabClass(testCase)
            obj = aod.schema.validators.Class([], ["char", "string"]);
            testCase.verifyTrue(obj.validate('test'));
            testCase.verifyTrue(obj.validate("test"));
            testCase.verifyFalse(obj.validate(123));
            testCase.verifyEqual(obj.text(), "char, string");

            obj2 = aod.schema.validators.Class([], "string, char");
            testCase.verifyEqual(obj, obj2);

            obj3 = aod.schema.validators.Class([], "string, double");
            testCase.verifyNotEqual(obj, obj3);
        end

        function EmptyMatlabClass(testCase)
            obj = aod.schema.validators.Class([], []);
            testCase.verifyFalse(obj.isSpecified());
            testCase.verifyTrue(obj.validate(123));
            testCase.verifyEqual(obj.text(), "[]");

            obj.setValue("string");
            testCase.verifyEqual(obj.Value, "string");
            testCase.verifyEqual(obj.text, "string");
            testCase.verifyTrue(obj.validate("hello"));
            testCase.verifyFalse(obj.validate('hello'));

            obj.setValue([]);
            testCase.verifyFalse(obj.isSpecified());
        end

        function MatlabClassEquality(testCase)
            obj1 = aod.schema.validators.Class([], []);
            obj2 = aod.schema.validators.Class([], "double");
            obj3 = aod.schema.validators.Class([], "double, char");
            testCase.verifyNotEqual(obj1, 123);
            testCase.verifyNotEqual(obj2, obj1);
            testCase.verifyNotEqual(obj3, obj2);
        end

        function MatlabClassComparison(testCase)
            import aod.schema.MatchType

            refObj1 = aod.schema.validators.Class([], "string");
            refObj2 = aod.schema.validators.Class([], []);

            testCase.verifyEqual(MatchType.CHANGED,...
                refObj1.compare(aod.schema.validators.Class([], "double")));
            testCase.verifyEqual(MatchType.SAME,...
                refObj1.compare(refObj1));
            testCase.verifyEqual(MatchType.REMOVED,...
                refObj1.compare(refObj2));
            testCase.verifyEqual(MatchType.ADDED,...
                refObj2.compare(refObj1));
        end

        function MatlabClassError(testCase)
            testCase.verifyError(...
                @() aod.schema.validators.Class([], "badclass"),...
                "Class:parse:InvalidClass");

            testCase.verifyError(...
                @() aod.schema.validators.Class([], 123),...
                "Class:parse:InvalidInput");
        end
    end

    methods (Test, TestTags="DefaultValue")
        function Default(testCase)
            obj = aod.schema.Default([], 2);
            testCase.verifyEqual("2", obj.text());
            testCase.verifyFalse(isempty(obj));

            % Change value
            obj.setValue(3);
            testCase.verifyEqual(obj.Value, 3);
        end

        function DefaultComparison(testCase)
            import aod.schema.MatchType

            refObj1 = aod.schema.Default([], 3);
            refObj2 = aod.schema.Default([], []);

            testCase.verifyEqual(MatchType.CHANGED,...
                refObj1.compare(aod.schema.Default([], "hey")));
            testCase.verifyEqual(MatchType.SAME,...
                refObj1.compare(refObj1));
            testCase.verifyEqual(MatchType.REMOVED,...
                refObj1.compare(refObj2));
            testCase.verifyEqual(MatchType.ADDED,...
                refObj2.compare(refObj1));
        end
    end

    methods (Test, TestTags="Description")
        function Description(testCase)
            obj = aod.schema.decorators.Description([], "test description");
            testCase.verifyEqual(obj.Value, "test description");
            obj.setValue("test");
            testCase.verifyEqual(obj.Value, "test");
            testCase.verifyEqual(obj.text(), "test");
        end

        function EmptyDescription(testCase)
            obj = aod.schema.decorators.Description([], []);
            testCase.verifyEqual(obj.Value, "");
        end

        function DescriptionComparison(testCase)
            import aod.schema.MatchType

            refObj1 = aod.schema.decorators.Description([], "test");
            refObj2 = aod.schema.decorators.Description([], []);

            testCase.verifyEqual(MatchType.CHANGED,...
                refObj1.compare(aod.schema.decorators.Description([], "text")));
            testCase.verifyEqual(MatchType.SAME,...
                refObj1.compare(refObj1));
            testCase.verifyEqual(MatchType.REMOVED,...
                refObj1.compare(refObj2));
            testCase.verifyEqual(MatchType.ADDED,...
                refObj2.compare(refObj1));
        end
    end

    methods (Test, TestTags="Specification")
        function Specification(testCase)
            sizeSpec = aod.schema.validators.Size([], "(1,:)");
            classSpec = aod.schema.validators.Class([], "double");
            descSpec = aod.schema.decorators.Description([], "This is a description");
            defaultSpec = aod.schema.Default(1);
        end
    end

    methods (Test, TestTags="EntityType")
        function EntityType(testCase)
            obj = aod.schema.validators.EntityType([], 'Calibration');
            testCase.verifyTrue(obj.isSpecified());

            [tf, ME] = obj.validate([]);
            testCase.confirmValid(tf, ME);

            [tf, ME] = obj.validate(123);
            testCase.verifyFalse(tf);
            testCase.verifyEqual(ME.identifier, 'AOData:EntityType:Invalid');
        end

        function EmptyEntityType(testCase)
            obj = aod.schema.validators.EntityType([], []);
            testCase.verifyFalse(obj.isSpecified());
            testCase.verifyEqual(obj.text(), "[]");
            testCase.verifyEqual(obj.jsonencode(), '[]');
        end

        function CoreEntityType(testCase)
            obj = aod.schema.validators.EntityType([], 'Calibration');

            [tf, ME] = obj.validate(aod.core.Calibration('Test', getDateYMD()));
            testCase.confirmValid(tf, ME);

            [tf, ME] = obj.validate(aod.core.Calibration("Test", getDateYMD()));
            testCase.confirmValid(tf, ME);

            [tf, ME] = obj.validate(aod.core.Epoch(1));
            testCase.verifyFalse(tf);
            testCase.verifyEqual(ME.identifier, 'AOData:EntityType:Invalid');
        end
    end

    methods (Test, TestTags="Enum")
        function Enum(testCase)
            obj = aod.schema.validators.Enum([], ["a", "b", "c"]);
            testCase.verifyTrue(obj.isSpecified());
            testCase.verifyEqual(obj, aod.schema.validators.Enum([], ["a", "b", "c"]));
            testCase.verifyNotEqual(obj, aod.schema.validators.Enum([], ["a", "b", "d"]));

            [tf, ME] = obj.validate("a");
            testCase.confirmValid(tf, ME);

            [tf, ME] = obj.validate("d");
            testCase.verifyFalse(tf);
            testCase.verifyEqual(ME.identifier, 'Enum:validate:InvalidEnum');
        end

        function EmptyEnum(testCase)
            obj = aod.schema.validators.Enum([], []);
            testCase.verifyFalse(obj.isSpecified());
            testCase.verifyEqual(obj.text(), "[]");
            testCase.verifyEqual(obj.jsonencode(), '[]');

            testCase.verifyTrue(obj.validate("d"));
        end
    end

    methods (Test, TestTags="Length")
        function Length(testCase)
            obj = aod.schema.validators.Length([], 3);
            testCase.verifyTrue(obj.isSpecified());
            testCase.verifyEqual(obj, aod.schema.validators.Length([], 3));
            testCase.verifyNotEqual(obj, aod.schema.validators.Length([], 4));
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
            testCase.verifyFalse(obj.isSpecified());
            testCase.verifyEqual(obj.text(), "[]");
            testCase.verifyEqual(obj.jsonencode(), '[]');

            [tf, ME] = obj.validate("d");
            testCase.confirmValid(tf, ME);

            obj.setValue(3);
            testCase.verifyTrue(obj.isSpecified());
            testCase.verifyEqual(obj.Value, 3);
            testCase.verifyEqual(obj.text(), "3");

            obj.setValue([]);
            testCase.verifyFalse(obj.isSpecified());
        end
    end

    methods (Test, TestTags="Count")
        function Count(testCase)
            obj = aod.schema.validators.Count([], 3);
            testCase.verifyTrue(obj.isSpecified());
            testCase.verifyEqual(obj, aod.schema.validators.Count([], 3));
            testCase.verifyNotEqual(obj, aod.schema.validators.Count([], 4));

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
            testCase.verifyFalse(obj.isSpecified());
            testCase.verifyEqual(obj.text(), "[]");
            testCase.verifyEqual(obj.jsonencode(), '[]');

            [tf, ME] = obj.validate("d");
            testCase.confirmValid(tf, ME);

            obj.setValue(3);
            testCase.verifyTrue(obj.isSpecified());
            testCase.verifyEqual(obj.text(), "3");

            obj.setValue([]);
            testCase.verifyFalse(obj.isSpecified());
        end
    end

    methods (Test, TestTags="Units")
        function Units(testCase)
            obj = aod.schema.decorators.Units([], "mV");
            testCase.verifyTrue(obj.isSpecified());
            testCase.verifyEqual(obj, aod.schema.decorators.Units([], "mV"));
            testCase.verifyNotEqual(obj, aod.schema.decorators.Units([], "mm"));


            obj.setValue(["mV"; "sec"]);
            testCase.verifyEqual(obj.Value, ["mV", "sec"]);
        end

        function EmptyUnits(testCase)
            obj = aod.schema.decorators.Units([], []);
            testCase.verifyFalse(obj.isSpecified());
            testCase.verifyEqual(obj.text(), "[]");
            testCase.verifyEqual(obj.jsonencode(), '[]');

            obj.setValue("mV");
            testCase.verifyTrue(obj.isSpecified());
            testCase.verifyEqual(obj.Value, "mV");
            testCase.verifyEqual(obj.text(), string('"mV"'));

            obj.setValue([]);
            testCase.verifyFalse(obj.isSpecified());
        end
    end

    methods (Test, TestTags="Extension")
        function Extension(testCase)

            obj = aod.schema.validators.Extension([], ".txt");
            testCase.verifyTrue(obj.isSpecified());
            testCase.verifyEqual(obj, aod.schema.validators.Extension([], ".txt"));
            testCase.verifyNotEqual(obj, aod.schema.validators.Extension([], ".json"));

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

        function ExtensionEmpty(testCase)
            obj = aod.schema.validators.Extension([], []);
            testCase.verifyFalse(obj.isSpecified());
            testCase.verifyEqual(obj.text(), "[]");
            testCase.verifyEqual(obj.jsonencode(), '[]');

            [tf, ME] = obj.validate("test.txt");
            testCase.confirmValid(tf, ME);

            obj.setValue(".txt");
            testCase.verifyTrue(obj.isSpecified());

            obj.setValue("");
            testCase.verifyFalse(obj.isSpecified());

        end

        function ExtensionErrors(testCase)
            testCase.verifyError(...
                @() aod.schema.validators.Extension([], [".txt", "csv"]),...
                "setExtension:InvalidExtensionFormat");

            testCase.verifyError(...
                @() aod.schema.validators.Extension([], [".txt", "csv"; ".dat", ".json"]),...
                "setExtension:InvalidSize");

            testCase.verifyError(...
                @() aod.schema.validators.Extension([], ["", ".json"]),...
                "setExtension:SomeValuesEmpty");
        end
    end

    methods (Test, TestTags="Minimum")
        function Minimum(testCase)
            obj = aod.schema.validators.Minimum([], 0);
            testCase.verifyTrue(obj.isSpecified());

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
            testCase.verifyFalse(obj.isSpecified());
            testCase.verifyEqual(obj.text(), "[]");
            testCase.verifyEqual(obj.jsonencode(), '[]');

            [tf, ME] = obj.validate(1);
            testCase.confirmValid(tf, ME);

            obj.setValue(1);
            testCase.verifyTrue(obj.isSpecified());
            testCase.verifyEqual(obj.text(), "1");

            obj.setValue([]);
            testCase.verifyFalse(obj.isSpecified());

            obj.setValue("[]");
            testCase.verifyFalse(obj.isSpecified());
        end
    end

    methods (Test, TestTags="Maximum")
        function Maximum(testCase)
            obj = aod.schema.validators.Maximum([], 3);
            testCase.verifyTrue(obj.isSpecified());

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
            testCase.verifyFalse(obj.isSpecified());
            testCase.verifyEqual(obj.text(), "[]");
            testCase.verifyEqual(obj.jsonencode(), '[]');

            [tf, ME] = obj.validate(1);
            testCase.confirmValid(tf, ME);

            obj.setValue(1);
            testCase.verifyTrue(obj.isSpecified());
            testCase.verifyEqual(obj.text(), "1");

            obj.setValue([]);
            testCase.verifyFalse(obj.isSpecified());

            obj.setValue("[]");
            testCase.verifyFalse(obj.isSpecified());
        end
    end

    methods (Test, TestTags="SpecUtil")
        function IsInputEmpty(testCase)
            obj = aod.schema.validators.size.FixedDimension([]);

            obj.setValue([]);
            testCase.verifyEmpty(obj.Length);
            obj.setValue("[]");
            testCase.verifyEmpty(obj.Length);
            obj.setValue("");
            testCase.verifyEmpty(obj.Length);

            obj.setValue(1);
            testCase.verifyEqual(obj.Length, 1);
            obj.setValue("1");
            testCase.verifyEqual(obj.Length, 1);
        end
    end

    methods (Test, TestTags="Utilities")
        function PackageContents(testCase)
            classNames = aod.specification.util.getPackageContents("aod.core", true);
            testCase.verifyFalse(ismember('aod.core.MixedEntitySet', classNames));

            classNames = aod.specification.util.getPackageContents("aod.core", false);
            testCase.verifyTrue(ismember('aod.core.MixedEntitySet', classNames));
        end
    end
end