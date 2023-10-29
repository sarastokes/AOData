classdef SpecificationTest < matlab.unittest.TestCase
% Tests specification of AOData subclasses
%
% Description:
%   Tests templates for specifying AOData subclasses
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

    methods (Test, TestTags="Size")
        function EmptySize(testCase)
            emptyObj = aod.schema.validators.Size();
            testCase.verifyFalse(emptyObj.isSpecified());
            testCase.verifyEqual(emptyObj.text(), "[]");
            testCase.verifyTrue(emptyObj.validate(123));
        end

        function SizeEquality(testCase)
            obj1 = aod.schema.validators.Size();
            obj2 = aod.schema.validators.Size("(1,:)");
            obj3 = aod.schema.validators.Size("(1,2)");
            obj4 = aod.schema.validators.Size("(2,1)");
            obj5 = aod.schema.validators.Size("(2,2,2)");

            testCase.verifyNotEqual(obj1, 123);
            testCase.verifyNotEqual(obj1, obj2);
            testCase.verifyNotEqual(obj2, obj3);
            testCase.verifyNotEqual(obj3, obj4);
            testCase.verifyNotEqual(obj4, obj5);
        end

        function SizeComparison(testCase)
            import aod.schema.MatchType

            refObj1 = aod.schema.validators.Size("(1,1)");
            refObj2 = aod.schema.validators.Size([]);

            testCase.verifyEqual(MatchType.CHANGED,...
                refObj1.compare(aod.schema.validators.Size("(1,:)")));
            testCase.verifyEqual(MatchType.SAME,...
                refObj1.compare(refObj1));
            testCase.verifyEqual(MatchType.UNEXPECTED,...
                refObj1.compare(refObj2));
            testCase.verifyEqual(MatchType.MISSING,...
                refObj2.compare(refObj1));

            testCase.verifyError(...
                @() refObj1.compare(aod.schema.validators.Class("string")),...
                "compare:UnlikeSpecificationTypes");
        end

        function SizeErrors(testCase)
            testCase.verifyError(...
                @() aod.schema.validators.Size(1),...
                "Size:InvalidDimensions");

            testCase.verifyError(...
                @() aod.schema.validators.Size("(1)"),...
                "Size:InvalidDimensions");
        end

        function FixedDimensions(testCase)
            ref1 = [aod.schema.validators.size.FixedDimension([], 1),...
                   aod.schema.validators.size.FixedDimension([], 2)];
            testCase.verifyNotEqual(ref1(1), ref1(2));
            testCase.verifyEqual(ref1(1), ref1(1));

            rowSize1a = aod.schema.validators.Size("(1,2)");
            testCase.verifyEqual(rowSize1a.text(), "(1,2)");
            testCase.verifyEqual(rowSize1a.Value(1), ref1(1));
            testCase.verifyEqual(rowSize1a.Value(2), ref1(2));

            rowSize1b = aod.schema.validators.Size("(1,2)");
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

            rowSize2a = aod.schema.validators.Size("(:,1)");
            testCase.verifyEqual(rowSize2a.text(), "(:,1)");

            testCase.verifyEqual(rowSize2a.Value, ref2);
            testCase.verifyEqual(rowSize2b.Value, rowSize2a.Value);
        end

        function UnrestrictedDimensions(testCase)
            ref3 = [aod.schema.validators.size.UnrestrictedDimension([]),...
                    aod.schema.validators.size.UnrestrictedDimension([])];

            rowSize3a = aod.schema.validators.Size("(:,:)");
            testCase.verifyEqual(rowSize3a.text(), "(:,:)");

            testCase.verifyEqual(rowSize3a.Value, ref3);
            testCase.verifyTrue(rowSize3a.validate(eye(3)));
            testCase.verifyFalse(rowSize3a.validate(ones(3,3,3)));
        end
    end

    methods (Test, TestTags="MatlabClass")
        function MatlabClass(testCase)
            obj1 = aod.schema.validators.Class('char');
            testCase.verifyTrue(obj1.validate('test'));

            expt = aod.core.Experiment('test', cd, getDateYMD());
            obj2 = aod.schema.validators.Class(findprop(expt, 'epochIDs'));
            testCase.verifyEqual(obj2.Value, "double");
            testCase.verifyTrue(obj2.validate(123));
            testCase.verifyFalse(obj2.validate('test'));

            testCase.verifyNotEqual(obj1, obj2);
        end

        function MultipleMatlabClass(testCase)
            obj = aod.schema.validators.Class(["char", "string"]);
            testCase.verifyTrue(obj.validate('test'));
            testCase.verifyTrue(obj.validate("test"));
            testCase.verifyFalse(obj.validate(123));
            testCase.verifyEqual(obj.text(), "char, string");

            obj2 = aod.schema.validators.Class("string, char");
            testCase.verifyEqual(obj, obj2);

            obj3 = aod.schema.validators.Class("string, double");
            testCase.verifyNotEqual(obj, obj3);
        end

        function EmptyMatlabClass(testCase)
            obj = aod.schema.validators.Class();
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
            obj1 = aod.schema.validators.Class([]);
            obj2 = aod.schema.validators.Class("double");
            obj3 = aod.schema.validators.Class("double, char");
            testCase.verifyNotEqual(obj1, 123);
            testCase.verifyNotEqual(obj2, obj1);
            testCase.verifyNotEqual(obj3, obj2);
        end

        function MatlabClassComparison(testCase)
            import aod.schema.MatchType

            refObj1 = aod.schema.validators.Class("string");
            refObj2 = aod.schema.validators.Class([]);

            testCase.verifyEqual(MatchType.CHANGED,...
                refObj1.compare(aod.schema.validators.Class("double")));
            testCase.verifyEqual(MatchType.SAME,...
                refObj1.compare(refObj1));
            testCase.verifyEqual(MatchType.UNEXPECTED,...
                refObj1.compare(refObj2));
            testCase.verifyEqual(MatchType.MISSING,...
                refObj2.compare(refObj1));
        end

        function MatlabClassError(testCase)
            testCase.verifyError(...
                @() aod.schema.validators.Class("badclass"),...
                "Class:parse:InvalidClass");

            testCase.verifyError(...
                @() aod.schema.validators.Class(123),...
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
            testCase.verifyEqual(MatchType.UNEXPECTED,...
                refObj1.compare(refObj2));
            testCase.verifyEqual(MatchType.MISSING,...
                refObj2.compare(refObj1));
        end
    end

    methods (Test, TestTags="Description")
        function Description(testCase)
            obj = aod.schema.decorators.Description("test description");
            testCase.verifyEqual(obj.Value, "test description");
            obj.setValue("test");
            testCase.verifyEqual(obj.Value, "test");
            testCase.verifyEqual(obj.text(), "test");
        end

        function EntityDescription(testCase)
            expt = aod.core.Experiment("test", cd, getDateYMD());
            p = findprop(expt, "epochIDs");
            obj2 = aod.schema.decorators.Description(p);
            testCase.verifyEqual(obj2.Value, string(p.Description));
        end

        function EmptyDescription(testCase)
            obj = aod.schema.decorators.Description([]);
            testCase.verifyEqual(obj.Value, "");
        end

        function DescriptionComparison(testCase)
            import aod.schema.MatchType

            refObj1 = aod.schema.decorators.Description("test");
            refObj2 = aod.schema.decorators.Description([]);

            testCase.verifyEqual(MatchType.CHANGED,...
                refObj1.compare(aod.schema.decorators.Description("text")));
            testCase.verifyEqual(MatchType.SAME,...
                refObj1.compare(refObj1));
            testCase.verifyEqual(MatchType.UNEXPECTED,...
                refObj1.compare(refObj2));
            testCase.verifyEqual(MatchType.MISSING,...
                refObj2.compare(refObj1));
        end
    end

    methods (Test, TestTags="Dataset")
        function DatasetFromInput(testCase)
            obj = aod.schema.Record([], "test", "NUMBER",...
                "Size", "(1,2)",...
                "Default", [2 2],...
                "Description", "This is a test");
        end

        function EmptyDataset(testCase)
            obj = aod.schema.Record([], "Test");
            obj.setType("TEXT");
            testCase.verifyEqual(obj.primitiveType,...
                aod.schema.primitives.PrimitiveTypes.TEXT);

            % Test assignment
            obj.assign("Size", "(1,1)",...
                "Description", "test",...
                "Default", "hey");
            testCase.verifyEqual(obj.Default.Value, "hey");
            testCase.verifyEqual(obj.Description.Value, "test");
            testCase.verifyEqual(obj.Class.Value, ["string", "char"]);
            testCase.verifyEqual(obj.Size.SizeType, ...
                aod.schema.validators.size.SizeTypes.SCALAR);
        end
    end

    methods (Test, TestTags="Specification")
        function Specification(testCase)
            sizeSpec = aod.schema.validators.Size("(1,:)");
            classSpec = aod.schema.validators.Class("double");
            descSpec = aod.schema.decorators.Description("This is a description");
            defaultSpec = aod.schema.Default(1);
        end

        function DatasetManager(testCase)
            obj = aod.schema.collections.DatasetCollection.populate('aod.core.Epoch');
            testCase.verifyEqual(obj.Count, 4);
            testCase.verifyNumElements(obj.Records, 4);
            testCase.verifyEqual("aod.core.Epoch", obj.className);

            testCase.verifyTrue(obj.has('ID'));
            testCase.verifyEmpty(obj.get('Blah'));
            testCase.verifyFalse(obj.has('Blah'));

            out = obj.text();
        end

        function DatasetManagerAccess(testCase)
        end

        function DatasetManagerError(testCase)
            obj = aod.schema.collections.DatasetCollection.populate('aod.core.Epoch');
            ep = aod.core.Epoch(1);

            testCase.verifyError(...
                @() obj.add(findprop(ep, 'ID')), "add:EntryExists");
            testCase.verifyError(...
                @() obj.add("NewProp"), 'add:AdditionNotSupported');

            testCase.verifyError(...
                @() aod.schema.collections.DatasetCollection.populate("aod.common.FileReader"),...
                "populate:InvalidInput");
        end
    end

    methods (Test, TestTags="Attribute")
        function AttributeNameSearch(testCase)
            import aod.infra.ErrorTypes

            AM = aod.schema.util.getAttributeSchema(...
                "aod.builtin.devices.DichroicFilter");
            testCase.verifyTrue(AM.has("Wavelength"));

            testCase.verifyFalse(AM.has("BadInput"));
            testCase.verifyWarning(...
                @()AM.get("BadInput", ErrorTypes.WARNING),...
                "get:EntryNotFound");

            testCase.verifyNotEqual(AM.code(), "");
        end

        function CoreEntityAttributes(testCase)
            obj = aod.builtin.devices.BandpassFilter(510, 20);
            p = obj.Schema.Attributes.get('Bandwidth');
            testCase.verifyEqual(p.Name, "Bandwidth");
            expAtt = aod.schema.util.getAttributeSchema( ...
                'aod.builtin.devices.BandpassFilter');
            p2 = expAtt.get('Bandwidth');
            testCase.verifyEqual(p2.Name, "Bandwidth");

            % Set/remove expected attribute
            obj.setAttr('Bandwidth', 30);
            testCase.verifyEqual(obj.attributes('Bandwidth'), 30);
            obj.removeAttr('Bandwidth');
            testCase.verifyTrue(obj.attributes.isKey('Bandwidth'));
            testCase.verifyEmpty(obj.attributes('Bandwidth'));

            % Set/remove adhoc attribute
            obj.setAttr('RandomParam', true);
            obj.removeAttr('RandomParam');
            testCase.verifyFalse(obj.attributes.isKey('RandomParam'));
        end
    end

    methods (Test, TestTags="Parser")
        function Parser(testCase)
            AM = aod.schema.util.getAttributeSchema("aod.core.Experiment");
            ip = AM.parse("Administrator", "test1", "Laboratory", "test2");
            testCase.verifyEqual(ip.Results.Administrator, "test1");
            testCase.verifyEqual(ip.Results.Laboratory, "test2");
        end
    end

    methods (Test, TestTags="Access")

        function AttributeManagerAccess(testCase)
            AM = aod.schema.util.getAttributeSchema(...
                'aod.builtin.devices.NeutralDensityFilter');
            testCase.verifyClass(AM, 'aod.schema.collections.AttributeCollection');
        end

        function PackageAccess(testCase)
            [DM, AM, S] = aod.specification.util.collectPackageSpecifications(...
                "aod.core", "Write", false);
            testCase.verifyEqual(numel(DM), numel(AM));

            f = fieldnames(S);
            testCase.verifyNumElements(f, 2);
            testCase.verifyEqual(f{1}, 'Namespaces');

            f = fieldnames(S.Namespaces);
            testCase.verifyNumElements(f, 1);
            testCase.verifyEqual(f{1}, 'aod');
        end

        function AttributeManagerComparison(testCase)
            import aod.schema.MatchType

            obj = aod.builtin.devices.Pellicle([30 70]);
            model = obj.Schema.Attributes.get('Model');
            manufacturer = obj.Schema.Attributes.get('Manufacturer');

            fields = ["Description", "Class", "Size", "Default"];

            % Equal in all but description
            details = model.compare(manufacturer);
            for i = 1:numel(fields)
                if fields(i) == "Description"
                    testCase.verifyEqual(details(fields(i)), MatchType.CHANGED);
                else
                    testCase.verifyEqual(details(fields(i)), MatchType.SAME);
                end
            end
        end
    end

    methods (Test, TestTags="Property")
        function PropertySpecification(testCase)
            prop = aod.util.templates.PropertySpecification("Test");
            prop.Class = "duration,double";
            testCase.verifyEqual(numel(prop.Class), 2);

            testCase.verifyError(...
                @() set(prop, "Class", "badclass"),...
                "PropertySpecification:InvalidClassName")
        end

        function DatasetManagerFromEntity(testCase)
            % Populated DatasetManager
            cEXPT = ToyExperiment(false);
            DM = aod.schema.collections.DatasetCollection.populate(cEXPT);
            testCase.verifyEqual(DM.Count, 4);
            testCase.verifyNumElements(DM.list(), 4);

            % Hard to test, but make sure it's error free
            DM.text();
            DM.struct();

            % Get dataset by name
            D = DM.get('experimentDate');
            testCase.verifyEqual(D.Name, "experimentDate");

            % Modify
            DM.set('experimentDate',...
                "Description", "test");
            testCase.verifyEqual(D.Description.Value, "test");
        end

        function DatasetManagerAltPopulate(testCase)
            DM1 = aod.schema.collections.DatasetCollection.populate( ...
                'aod.core.Experiment');
            DM2 = aod.schema.collections.DatasetCollection.populate( ...
                meta.class.fromName('aod.core.Experiment'));

            testCase.verifyEqual(DM1.Count, DM2.Count);
        end

        function EmptyDatasetManager(testCase)
            obj = aod.schema.collections.DatasetCollection();
            testCase.verifyEmpty(obj.list());
            testCase.verifyEqual(obj.text(), "Empty DatasetManager");
            testCase.verifyEmpty(fieldnames(obj.struct()));

            [tf, idx] = obj.has('DsetName');
            testCase.verifyFalse(tf);
            testCase.verifyEmpty(idx);
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