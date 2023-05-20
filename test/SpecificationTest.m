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

%#ok<*MANU,*NASGU> 

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
            testCase.verifyEqual(obj.text(), "");

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
            testCase.verifyEqual('2', obj.text());
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

    methods (Test, TestTags="DataObject")
        function DataObjectFromMetaclass(testCase)
            % All but size
            obj1 = aod.specification.DataObject(findprop(testCase.TEST_OBJ, 'PropC'));
            testCase.verifyTrue(obj1.validate(123));
            testCase.verifyFalse(obj1.validate("bad"));
            testCase.verifyEmpty(obj1.Size);
            testCase.verifyEqual(obj1.Default.Value, 1);
            testCase.verifyEqual(obj1.Class.Value, "double");

            objD = aod.specification.DataObject(findprop(testCase.TEST_OBJ, 'PropD'));
            testCase.verifyEqual(obj1.Description.Value, "This is PropD");

            % All fields
            obj2 = aod.specification.DataObject(findprop(testCase.TEST_OBJ, 'PropB'));
            testCase.verifyTrue(obj2.validate([1 2 3]'));
            testCase.verifyFalse(obj2.validate([1 2 3]));

            % No description
            objA = aod.specification.DataObject(findprop(testCase.TEST_OBJ, 'PropA'));
            testCase.verifyEmpty(objA.Description);
        end

        function DataObjectFromInput(testCase)
            obj = aod.specification.DataObject('test',...
                "Size", "(1,2)",...
                "Class", "double",...
                "Function", {@mustBeNumeric},...
                "Default", [2 2],...
                "Description", "This is a test");
        end

        function EmptyDataObject(testCase)
            obj = aod.specification.DataObject("mytest");
            testCase.verifyEmpty(obj.Default);
            testCase.verifyEmpty(obj.Functions);
            testCase.verifyEmpty(obj.Class);
            testCase.verifyEmpty(obj.Size);
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
    end

    methods (Test, TestTags="Parameter")
        function ParameterNameSearch(testCase)
            import aod.util.ErrorTypes

            PM = aod.util.ParameterManager();
            PM.add('NewParam');

            % Search for parameter that doesn't exist
            p0 = PM.get('NewParam');
            testCase.verifyTrue(strcmp(p0.Name, "NewParam"));
            
            % Search for parameter that exists
            p1 = PM.get('BadParam', ErrorTypes.NONE);
            testCase.verifyEmpty(p1);
            testCase.verifyError(...
                @() PM.get('BadParam', ErrorTypes.ERROR),...
                "get:ParameterNotFound");
            testCase.verifyWarning(...
                @() PM.get('BadParam', ErrorTypes.WARNING),...
                "get:ParameterNotFound");
        end

        function ParameterAddition(testCase)
            PM = aod.util.ParameterManager();
        end

        function CoreEntityParameters(testCase)
            obj = aod.builtin.devices.BandpassFilter(510, 20);
            p = obj.expectedParameters.get('Bandwidth');
            testCase.verifyEqual(p.Name, 'Bandwidth');

            % Set/remove expected parameter
            obj.setParam('Bandwidth', 30);
            testCase.verifyEqual(obj.parameters('Bandwidth'), 30);
            obj.removeParam('Bandwidth');
            testCase.verifyTrue(obj.parameters.isKey('Bandwidth'));
            testCase.verifyEmpty(obj.parameters('Bandwidth'));

            % Set/remove adhoc parameter
            obj.setParam('RandomParam', true);
            obj.removeParam('RandomParam');
            testCase.verifyFalse(obj.parameters.isKey('RandomParam'));
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

        function ExpectedDataset(testCase)
            ED = aod.util.templates.ExpectedDataset("Test",...
                "double,duration", [], {@isnumeric},...
                "This is a test class", "seconds");
            testCase.verifyEqual(numel(ED.Class), 2);

            testCase.verifyError(...
                @()set(ED, "Validation", "double"),...
                "MATLAB:validation:UnableToConvert");
            %testCase.verifyError(...
            %    @()set(ED, "Class", "badclass"),...
            %    "parseClassName:InvalidClass");
        end

        function DatasetManager(testCase)
            % Empty DatasetManager
            DM = aod.util.DatasetManager();
            testCase.verifyEqual(DM.Count, 0);
            testCase.verifyEmpty(DM.list());
            
            % Add a parameter
            DM.add('TestParam', "double", 0, {@isnumeric},...
                "This is a test parameter", "seconds");
            testCase.verifyEqual(DM.Count, 1);

            % Overwrite existing parameter
            testCase.verifyWarning(...
                @() DM.add('TestParam', 'double'), "add:OverwroteDataset");
            
            ED = aod.util.templates.ExpectedDataset("TestParam");
            testCase.verifyWarning(...
                @() DM.add(ED), "add:OverwroteDataset");
            
            warning('off', "add:OverwroteDataset");
            DM.add('TestParam', "double", 2, {@isnumeric},...
                "This is an overwritten test parameter", "seconds");
            testCase.verifyEqual(DM.Count, 1);
            ED = DM.get('TestParam');
            testCase.verifyEqual(ED.Default, 2);
            warning('on', "add:OverwroteDataset");
        end

        function PopulatedDatasetManager(testCase)
            % Populated DatasetManager
            cEXPT = ToyExperiment(false);
            DM = aod.util.DatasetManager.populate(cEXPT);
            testCase.verifyEqual(DM.Count, 4);
            testCase.verifyNumElements(DM.list, 4);

            % Remove a parameter
            DM.remove('epochIDs');
            testCase.verifyEqual(DM.Count, 3);

            % Clear all parameters
            DM.clear();
            testCase.verifyEqual(DM.Count, 0);
        end
    end
end 