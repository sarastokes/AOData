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

    properties
        TEST_OBJ
    end
    
    methods (TestClassSetup)
        function setup(testCase)
            testCase.TEST_OBJ = test.TestSpecificationObject();
        end
    end

    methods (Test, TestTags="Size")
        function Size(testCase)
            propObj = aod.specification.Size(...
                findprop(testCase.TEST_OBJ, 'PropA'));
            testCase.verifyEqual( ...
                [propObj.Value(1).Length, propObj.Value(2).Length],...
                [aod.specification.size.FixedDimension(1).Length,...
                 aod.specification.size.FixedDimension(2).Length]);
        end

        function EmptySize(testCase) 
            emptyObj = aod.specification.Size();
            testCase.verifyEmpty(emptyObj);
            testCase.verifyEqual(emptyObj.text(), "[]");
            testCase.verifyTrue(emptyObj.validate(123));
        end

        function SizeEquality(testCase)
            obj1 = aod.specification.Size();
            obj2 = aod.specification.Size("(1,:)");
            obj3 = aod.specification.Size([1, 2]);
            obj4 = aod.specification.Size([2, 1]);
            obj5 = aod.specification.Size([2, 2, 2]);

            testCase.verifyNotEqual(obj1, 123);
            testCase.verifyNotEqual(obj1, obj2);
            testCase.verifyNotEqual(obj2, obj3);
            testCase.verifyNotEqual(obj3, obj4);
            testCase.verifyNotEqual(obj4, obj5);
        end

        function SizeErrors(testCase)
            testCase.verifyError(...
                @() aod.specification.Size(1),...
                "Size:InvalidDimensions");
            
            testCase.verifyError(...
                @() aod.specification.Size("(1)"),...
                "Size:InvalidDimensions");
        end

        function FixedDimensions(testCase)
            ref1 = [aod.specification.size.FixedDimension(1),...
                   aod.specification.size.FixedDimension(2)];
            testCase.verifyNotEqual(ref1(1), ref1(2));
            testCase.verifyEqual(ref1(1), ref1(1));
            
            rowSize1a = aod.specification.Size([1,2]);
            testCase.verifyEqual(rowSize1a.text(), "(1,2)");
            testCase.verifyEqual(rowSize1a.Value(1), ref1(1));
            testCase.verifyEqual(rowSize1a.Value(2), ref1(2));

            rowSize1b = aod.specification.Size("(1,2)");
            testCase.verifyClass(rowSize1b.Value, ...
                "aod.specification.size.FixedDimension");
            testCase.verifyTrue(rowSize1b.validate([1 2]));
            testCase.verifyFalse(rowSize1b.validate([1 2]'));
            testCase.verifyEqual(rowSize1a, rowSize1b);

            ref1(1).setValue(2);
            testCase.verifyEqual(ref1(1).Length, 2);
            testCase.verifyTrue(ref1(1).validate('2'));
        end

        function MixedDimensions(testCase)
            ref2 = [aod.specification.size.UnrestrictedDimension(),...
                    aod.specification.size.FixedDimension(1)];

            rowSize2a = aod.specification.Size("(:,1)");
            rowSize2b = aod.specification.Size(findprop(testCase.TEST_OBJ, "PropB"));
            testCase.verifyEqual(rowSize2a.text(), "(:,1)");

            testCase.verifyEqual(rowSize2a.Value, ref2);
            testCase.verifyEqual(rowSize2b.Value, rowSize2a.Value);
        end

        function UnrestrictedDimensions(testCase)
            ref3 = [aod.specification.size.UnrestrictedDimension(),...
                    aod.specification.size.UnrestrictedDimension()];

            rowSize3a = aod.specification.Size("(:,:)");
            testCase.verifyEqual(rowSize3a.text(), "(:,:)");

            testCase.verifyEqual(rowSize3a.Value, ref3);
            testCase.verifyTrue(rowSize3a.validate(eye(3)));
            testCase.verifyFalse(rowSize3a.validate(ones(3,3,3)));
        end
    end

    methods (Test, TestTags="MatlabClass")
        function MatlabClass(testCase)
            obj1 = aod.specification.MatlabClass('char');
            testCase.verifyTrue(obj1.validate('test'));

            expt = aod.core.Experiment('test', cd, getDateYMD());
            obj2 = aod.specification.MatlabClass(findprop(expt, 'epochIDs'));
            testCase.verifyEqual(obj2.Value, "double");
            testCase.verifyTrue(obj2.validate(123));
            testCase.verifyFalse(obj2.validate('test'));

            testCase.verifyNotEqual(obj1, obj2);
        end

        function MultipleMatlabClass(testCase)
            obj = aod.specification.MatlabClass(["char", "string"]);
            testCase.verifyTrue(obj.validate('test'));
            testCase.verifyTrue(obj.validate("test"));
            testCase.verifyFalse(obj.validate(123));
            testCase.verifyEqual(obj.text(), "char, string");

            obj2 = aod.specification.MatlabClass("string, char");
            testCase.verifyEqual(obj, obj2);

            obj3 = aod.specification.MatlabClass("string, double");
            testCase.verifyNotEqual(obj, obj3);
        end

        function EmptyMatlabClass(testCase)
            obj = aod.specification.MatlabClass();
            testCase.verifyEmpty(obj);
            testCase.verifyTrue(obj.validate(123));
            testCase.verifyEqual(obj.text(), "[]");

            obj.setValue("string");
            testCase.verifyEqual(obj.Value, "string");
            testCase.verifyEqual(obj.text, "string");
            testCase.verifyTrue(obj.validate("hello"));
            testCase.verifyFalse(obj.validate('hello'));

            obj.setValue([]);
            testCase.verifyEmpty(obj);
        end

        function MatlabClassEquality(testCase)
            obj1 = aod.specification.MatlabClass([]);
            obj2 = aod.specification.MatlabClass("double");
            obj3 = aod.specification.MatlabClass("double, char");
            testCase.verifyNotEqual(obj1, 123);
            testCase.verifyNotEqual(obj2, obj1);
            testCase.verifyNotEqual(obj3, obj2);
        end

        function MatlabClassError(testCase)
            testCase.verifyError(...
                @() aod.specification.MatlabClass("badclass"),...
                "MatlabClass:InvalidClass");

            testCase.verifyError(...
                @() aod.specification.MatlabClass(123),...
                "MatlabClass:InvalidInput");
        end
    end

    methods (Test, TestTags="DefaultValue")
        function DefaultValue(testCase)

            obj = aod.specification.DefaultValue(2);
            testCase.verifyEqual("2", obj.text());
            testCase.verifyTrue(obj.validate(true));
            testCase.verifyFalse(isempty(obj));

            % Change value
            obj.setValue(3);
            testCase.verifyEqual(obj.Value, 3);
        end
    end

    methods (Test, TestTags="Description")
        function Description(testCase)
            obj = aod.specification.Description("test description");
            testCase.verifyEqual(obj.Value, "test description");
            obj.setValue("test");
            testCase.verifyEqual(obj.Value, "test");
            testCase.verifyEqual(obj.text(), "test");


            expt = aod.core.Experiment("test", cd, getDateYMD());
            p = findprop(expt, "epochIDs");
            obj2 = aod.specification.Description(p);
            testCase.verifyEqual(obj2.Value, string(p.Description));
        end

        function EmptyDescription(testCase)
            obj = aod.specification.Description([]);
            testCase.verifyEqual(obj.Value, "");

        end
    end

    methods (Test, TestTags="Functions")
        function FunctionValidation(testCase)
            obj = aod.specification.ValidationFunction(...
                {@mustBeNumeric, @(x) x > 100});
            testCase.verifyFalse(isempty(obj));
            testCase.verifyTrue(obj.validate(123))
            testCase.verifyFalse(obj.validate(50));
            testCase.verifyFalse(obj.validate("test"));

            obj.setValue([]);
            testCase.verifyTrue(obj.validate("test"));


            expt = aod.core.Experiment("test", cd, getDateYMD());
            p = findprop(expt, "epochIDs");
            obj2 = aod.specification.ValidationFunction(p);
            testCase.verifyEmpty(obj2.Value);
        end

        function EmptyFunctions(testCase)
            obj = aod.specification.ValidationFunction();
            testCase.verifyEmpty(obj);
            testCase.verifyTrue(obj.validate(123)); 
        end

        function FunctionErrors(testCase)
            testCase.verifyError(...
                @() aod.specification.ValidationFunction(123),...
                "validateFunctionHandles:InvalidInput");
        end
    end

    methods (Test, TestTags="Dataset")
        function EntryFromMetaclass(testCase)
            % All but size
            obj1 = aod.specification.Entry(findprop(testCase.TEST_OBJ, 'PropC'));
            testCase.verifyTrue(obj1.validate(123));
            testCase.verifyFalse(obj1.validate("bad"));
            testCase.verifyEmpty(obj1.Size);
            testCase.verifyEqual(obj1.Default.Value, 1);
            testCase.verifyEqual(obj1.Class.Value, "double");

            %objD = aod.specification.Entry(findprop(testCase.TEST_OBJ, 'PropD'));
            %testCase.verifyEqual(obj1.Description.Value, "This is PropD");

            % All fields
            obj2 = aod.specification.Entry(findprop(testCase.TEST_OBJ, 'PropB'));
            testCase.verifyTrue(obj2.validate([1 2 3]'));
            testCase.verifyFalse(obj2.validate([1 2 3]));

            % No description
            objA = aod.specification.Entry(findprop(testCase.TEST_OBJ, 'PropA'));
            testCase.verifyEmpty(objA.Description);
        end

        function DatasetFromInput(testCase)
            obj = aod.specification.Entry('test',...
                "Size", "(1,2)",...
                "Class", "double",...
                "Function", {@mustBeNumeric},...
                "Default", [2 2],...
                "Description", "This is a test");
        end

        function EmptyDataset(testCase)
            obj0 = aod.specification.Entry();

            obj = aod.specification.Entry("MyProp");
            testCase.verifyEmpty(obj.Default);
            testCase.verifyEmpty(obj.Functions);
            testCase.verifyEmpty(obj.Class);
            testCase.verifyEmpty(obj.Size);

            % Test assignment
            obj.assign("Size", "(1,1)",...
                "Description", "test",...
                "Class", "string",...
                "Default", "hey",...
                "Function", {@mustBeTextScalar});
            testCase.verifyEqual(obj.Default.Value, "hey");
            testCase.verifyEqual(obj.Description.Value, "test");
            testCase.verifyEqual(obj.Class.Value, ["string", "char"]);
            testCase.verifyEqual(obj.Size.SizeType, ...
                aod.specification.SizeTypes.SCALAR);
        end
    end

    methods (Test, TestTags="Specification")
        function Specification(testCase)
            sizeSpec = aod.specification.Size("(1,:)"); 
            classSpec = aod.specification.MatlabClass("double");
            descSpec = aod.specification.Description("This is a description");
            defaultSpec = aod.specification.DefaultValue(1);
            fcnSpec = aod.specification.ValidationFunction(@mjstBeNumeric);
        end

        function DatasetManager(testCase)
            obj = aod.specification.DatasetManager.populate('aod.core.Epoch');
            testCase.verifyEqual(obj.Count, 4);
            testCase.verifyNumElements(obj.Entries, 4);
            testCase.verifyEqual("aod.core.Epoch", obj.className);

            testCase.verifyTrue(obj.has('ID'));
            testCase.verifyEmpty(obj.get('Blah'));
            testCase.verifyFalse(obj.has('Blah'));

            out = obj.text();
            testCase.verifySize(obj.table(), [4 6]);
        end

        function DatasetManagerAccess(testCase)
            DM = aod.specification.util.getDatasetSpecification(...
                'aod.builtin.devices.NeutralDensityFilter');
            testCase.verifyClass(DM, 'aod.specification.DatasetManager');
        end

        function DatasetManagerError(testCase)
            obj = aod.specification.DatasetManager.populate('aod.core.Epoch');
            ep = aod.core.Epoch(1);

            testCase.verifyError(...
                @() obj.add(findprop(ep, 'ID')), "add:EntryExists");
            testCase.verifyError(...
                @() obj.add("NewProp"), "add:InvalidInput");

            testCase.verifyError(...
                @() aod.specification.DatasetManager.populate("aod.common.FileReader"),...
                "populate:InvalidInput");
        end
    end

    methods (Test, TestTags="Attribute")
        function AttributeNameSearch(testCase)
            import aod.infra.ErrorTypes

            AM = aod.specification.util.getAttributeSpecification(...
                "aod.builtin.devices.DichroicFilter");
            testCase.verifyTrue(AM.has("Wavelength"));

            testCase.verifyFalse(AM.has("BadInput"));
            testCase.verifyWarning(...
                @()AM.get("BadInput", ErrorTypes.WARNING),...
                "get:EntryNotFound");
        end

        function CoreEntityAttributes(testCase)
            obj = aod.builtin.devices.BandpassFilter(510, 20);
            p = obj.expectedAttributes.get('Bandwidth');
            testCase.verifyEqual(p.Name, "Bandwidth");
            expAtt = aod.specification.util.getAttributeSpecification( ...
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
            AM = aod.specification.util.getAttributeSpecification("aod.core.Experiment");
            ip = AM.parse("Administrator", "test1", "Laboratory", "test2");
            testCase.verifyEqual(ip.Results.Administrator, "test1");
            testCase.verifyEqual(ip.Results.Laboratory, "test2");
        end
    end

    methods (Test, TestTags="Access")

        function AttributeManagerAccess(testCase)
            AM = aod.specification.util.getAttributeSpecification(...
                'aod.builtin.devices.NeutralDensityFilter');
            testCase.verifyClass(AM, 'aod.specification.AttributeManager');
        end
        
        function PackageAccess(testCase)
            [DM, AM, S] = aod.specification.util.collectPackageSpecifications(...
                "aod.core", "Write", false);
            testCase.verifyEqual(numel(DM), numel(AM));
            
            f = fieldnames(S);
            testCase.verifyNumElements(f, 2);
            testCase.verifyEqual(f{1}, 'Namespace');

            f = fieldnames(S.Namespace);
            testCase.verifyNumElements(f, 1);
            testCase.verifyEqual(f{1}, 'aod');
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
            DM = aod.specification.DatasetManager.populate(cEXPT);
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
            DM1 = aod.specification.DatasetManager.populate( ...
                'aod.core.Experiment');
            DM2 = aod.specification.DatasetManager.populate( ...
                meta.class.fromName('aod.core.Experiment'));

            testCase.verifyEqual(DM1.Count, DM2.Count);
        end

        function EmptyDatasetManager(testCase)
            obj = aod.specification.DatasetManager();
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