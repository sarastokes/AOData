classdef SchemaTest < matlab.unittest.TestCase
% Tests schemas for AOData subclasses
%
% Description:
%   Tests the classes for schema management
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

    properties
        EXPT
    end

    methods (TestClassSetup)
        function setupClass(testCase)
            testCase.EXPT = ToyExperiment(false, false);
        end
    end

    methods (Test, TestTags="Schema")
        function SchemaEquality(testCase)
            obj1 = aod.builtin.devices.Pinhole(20);
            obj2 = aod.builtin.devices.Pinhole(30);
            testCase.verifyNotEqual(obj1, obj2);
            testCase.verifyEqual(obj1.Schema, obj2.Schema);

            % Same schema, different schema subclass (no entity instance)
            schema = aod.schema.util.StandaloneSchema('aod.builtin.devices.Pinhole');
            testCase.verifyEqual(obj1.Schema, schema);
        end

        function SchemaUndefined(testCase)
            obj = aotest.TestDevice("AttrOne", [2 2]);
            [dsets, attrs, files, ME] = obj.Schema.getUndefined("None");
            testCase.verifyNumElements(dsets, 2);
            testCase.verifyNumElements(attrs, 1);
            testCase.verifyEmpty(files);
            testCase.verifyEqual(dsets, ["EmptyProp", "DependentProp"]);
            testCase.verifyEqual(attrs, "AttrThree");
            testCase.verifyTrue(contains(ME.message, "2 datasets, 1 attributes"));
        end
    end

    methods (Test, TestTags="SchemaCollection")
        function SchemaCollection(testCase)
            import aod.common.EntityTypes

            obj = aod.schema.collections.SchemaCollection(testCase.EXPT);
            testCase.verifyNumElements(obj.Schemas, 20);
            testCase.verifyNumElements(find(obj.entityTypes == EntityTypes.Epoch), 1);

            T = obj.table();
            testCase.verifySize(T, [20 3]);
        end
    end

    methods (Test, TestTags="ItemCollection")
        function ItemCollection(testCase)
            obj = aod.schema.collections.ItemCollection();
            testCase.verifyEqual(obj.Count, 0);

            % Add a primitive
            obj.add(aod.schema.Item(obj, "Test", "BOOLEAN", "Size", "(1,1)"));
            testCase.verifyEqual(obj.Count, 1);

            % Remove a primitive
            obj.remove("Test");
            testCase.verifyEqual(obj.Count, 0);

            % Re-add a primitive, then another
            obj.add(aod.schema.Item(obj, "P1", "BOOLEAN", "Default", false));
            obj.add(aod.schema.Item(obj, "P2", "NUMBER", "Size", "(1,1)", "Units", "mV"));
            testCase.verifyEqual(obj.Count, 2);

            testCase.verifyEqual(obj.has("P1"));
            testCase.verifyClass(obj.get("P1").primitiveType, PrimitiveTypes.BOOLEAN);
            testCase.verifyClass(obj.get("P2").primitiveType, PrimitiveTypes.NUMBER);
        end

        function ItemCollectionErrors(testCase)
            obj = aod.schema.collections.ItemCollection([]);
            testCase.verifyError(...
                @() obj.get("P1"), "get:ItemNotFound");
            testCase.verifyWarning(...
                @() obj.get("P1", "WARNING"), "get:ItemNotFound");
        end
    end

    methods (Test, TestTags="AttributeCollection")
        function AttributeCollectionAccess(testCase)
            schema = aod.schema.util.StandaloneSchema(...
                'aod.builtin.devices.NeutralDensityFilter');
            testCase.verifyClass(schema.Attributes, 'aod.schema.collections.AttributeCollection');
        end

        function Parser(testCase)
            schema = aod.schema.util.StandaloneSchema("aod.core.Experiment");
            ip = schema.Attributes.parse("Administrator", "test1", "Laboratory", "test2");
            testCase.verifyEqual(ip.Results.Administrator, "test1");
            testCase.verifyEqual(ip.Results.Laboratory, "test2");
        end

        function AttributeNameSearch(testCase)
            import aod.infra.ErrorTypes

            schema = aod.schema.util.StandaloneSchema(...
                "aod.builtin.devices.DichroicFilter");
            testCase.verifyTrue(schema.Attributes.has("Wavelength"));

            testCase.verifyFalse(schema.Attributes.has("BadInput"));
            testCase.verifyWarning(...
                @()schema.Attributes.get("BadInput", ErrorTypes.WARNING),...
                "get:EntryNotFound");

            testCase.verifyNotEqual(schema.Attributes.code(), "");
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

        function CoreEntityAttributes(testCase)
            obj = aod.builtin.devices.BandpassFilter(510, 20);
            p = obj.Schema.Attributes.get('Bandwidth');
            testCase.verifyEqual(p.Name, "Bandwidth");
            schema = aod.schema.util.StandaloneSchema('aod.builtin.devices.BandpassFilter');
            expAtt = schema.Attributes;
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


    methods (Test, TestTags="Record")
        function Record(testCase)
            obj = aod.schema.Record([], 'Test', 'Number',...
                'Maximum', 3, 'Size', '(1,1)');
            [tf, ME] = obj.validate(3);
            testCase.verifyTrue(tf);
            testCase.verifyEmpty(ME);

            [tf, ME] = obj.validate(4, aod.infra.ErrorTypes.NONE);
            testCase.verifyFalse(tf);
            testCase.verifyNotEmpty(ME);
            if ~isempty(ME)  % avoid error cutting test short
                testCase.verifyNumElements(ME.cause, 1);
                testCase.verifyEqual(ME.identifier, 'validate:Failed');
                testCase.verifyEqual(ME.cause{1}.identifier, 'validate:MaximumExceeded');
            end

            testCase.verifyError(...
                @() obj.validate([4 4]), 'validate:SchemaViolationsDetected');
            [tf, ME] = obj.validate([4 4], aod.infra.ErrorTypes.NONE);
            testCase.verifyFalse(tf);
            testCase.verifyNotEmpty(ME);
            if ~isempty(ME)
                testCase.verifyNumElements(ME.cause, 2);
            end
        end

        function RecordFromInput(testCase)
            obj = aod.schema.Record([], "test", "NUMBER",...
                "Size", "(1,2)",...
                "Default", [2 2],...
                "Description", "This is a test");
            testCase.verifyEqual(obj.primitiveType, ...
                aod.schema.PrimitiveTypes.NUMBER);
            testCase.verifyTrue(obj.Primitive.Size.isSpecified());
        end

        function EmptyRecord(testCase)
            obj = aod.schema.Record([], "Test", "Unknown");
            obj.setPrimitive("TEXT");
            testCase.verifyEqual(obj.primitiveType,...
                aod.schema.PrimitiveTypes.TEXT);

            % Test assignment
            obj.assign("Size", "(1,1)",...
                "Description", "test",...
                "Default", "hey");
            testCase.verifyEqual(obj.Primitive.Default.Value, "hey");
            testCase.verifyEqual(obj.Primitive.Description.Value, "test");
            testCase.verifyEqual(obj.Primitive.Class.Value, "string");
            testCase.verifyEqual(obj.Primitive.Size.SizeType, ...
                aod.schema.validators.size.SizeTypes.SCALAR);
        end
    end

    methods (Test, TestTags="DatasetCollection")
        function DatasetCollection(testCase)
            obj = aod.schema.collections.DatasetCollection.populate('aod.core.Calibration');
            testCase.verifyNotEmpty(obj);

            testCase.verifyEqual(2, obj.Count);
            testCase.verifyEqual(["calibrationDate", "Target"], obj.Contents);

            testCase.verifyClass(obj.Records(1).Parent, 'aod.schema.collections.DatasetCollection');
        end

        function DatasetCollection2(testCase)
            obj = aod.schema.collections.DatasetCollection.populate('aod.core.Epoch');
            testCase.verifyEqual(obj.Count, 4);
            testCase.verifyNumElements(obj.Records, 4);
            testCase.verifyEqual("aod.core.Epoch", obj.className);

            testCase.verifyTrue(obj.has('ID'));
            testCase.verifyEmpty(obj.get('Blah'));
            testCase.verifyFalse(obj.has('Blah'));

            out = obj.text(); %#ok<NASGU>
        end

        function DatasetCollectionFromEntity(testCase)
            cEXPT = ToyExperiment(false);
            DM = aod.schema.collections.DatasetCollection.populate(cEXPT);
            testCase.verifyEqual(DM.Count, 4);
            testCase.verifyNumElements(DM.list(), 4);

            % TODO: add tests, currently just ensures error free
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

        function EmptyDatasetCollection(testCase)
            obj = aod.schema.collections.DatasetCollection([]);
            testCase.verifyEmpty(obj.list());
            testCase.verifyEqual(obj.text(), "Empty DatasetManager");
            S = obj.struct();
            testCase.verifyEmpty(fieldnames(S.Datasets));

            [tf, idx] = obj.has('DsetName');
            testCase.verifyFalse(tf);
            testCase.verifyEmpty(idx);
        end

        function DatasetCollectionErrors(testCase)
            obj = aod.schema.collections.DatasetCollection.populate('aod.core.Calibration');
            testCase.verifyError(...
                @() obj.remove('Target'), "remove:DatasetRemovalNotSupported");

            testCase.verifyError(...
                @() obj.add('NewProp', 'TEXT', 'Description', 'this is a test'),...
                "add:AdditionNotSupported");

            testCase.verifyError(...
                @() aod.schema.collections.DatasetCollection.populate(123),...
                "populate:InvalidInput");
            testCase.verifyError(...
                @() aod.schema.collections.DatasetCollection.populate("aod.common.FileReader"),...
                "populate:InvalidInput");
        end
    end

    methods (Test, TestTags="FileCollection")
        function FileCollection(testCase)
            obj = aod.schema.collections.FileCollection.populate('aod.core.Calibration');
            testCase.verifyEmpty(obj);
            testCase.verifyEqual(obj.Count, 0);
            testCase.verifyEqual(obj.className, "aod.core.Calibration");

            obj.add('TestFile', 'Description', 'A test file', 'Extension', '.txt');
            testCase.verifyNotEmpty(obj);
            testCase.verifyEqual(obj.Count, 1);
            testCase.verifyEqual(obj.Records(1).Name, "TestFile");
            testCase.verifyEqual(obj.Contents, "TestFile");

            obj.remove('TestFile');
            testCase.verifyEmpty(obj);
            testCase.verifyEqual(obj.Count, 0);
            testCase.verifyEmpty(obj.Contents);

            % Make sure we can add back again without empty array error
            % Add in an unecessary "file" primitiveType specification as '
            % used for DatasetCollection and AttributeCollection to ensure
            % it doesn't throw an error
            obj.add('TestFile2', 'File', 'Description', 'A test file');
            testCase.verifyEqual(obj.Count, 1);
        end

        function FileCollectionErrors(testCase)
            obj = aod.schema.collections.FileCollection.populate('aod.core.Calibration');
            testCase.verifyError(...
                @() obj.add('Test', 'number', 'Description', 'Bad spec'),...
                "add:InvalidPrimitiveType");
        end
    end

    methods
        function IsPrimitiveType(testCase)
            obj = aod.schema.Record([], 'Test', 'Number',...
                'Maximum', 3, 'Size', '(1,1)');
            testCase.verifyTrue(aod.schema.util.isPrimitiveType(obj, 'number'));
            testCase.verifyFalse(aod.schema.util.isPrimitiveType(obj, 'text'));

            testCase.verifyTrue(aod.schema.util.isPrimitiveType(obj.Primitive, 'number'));
            testCase.verifyFalse(aod.schema.util.isPrimitiveType(obj.Primitive, 'text'));
        end
    end
end