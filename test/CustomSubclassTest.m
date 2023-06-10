classdef CustomSubclassTest < matlab.uitest.TestCase
% Tests the subclass generator classes
%
% Syntax:
%   results = runtests('CustomSubclassTest')
%
% See also:
%   runAODataTestSuite, runTestWithDebug, runtests
%
% Tags of CustomSubclassController uicomponents:
% Buttons: "WriteButton", "UpdateButton", "FileBrowserButton"
%          "AddDatasetButton", "RemoveDatasetButton", "EditDatasetButton"
% Panels: "ClassNamePanel", "FilePathPanel", "EntityTypePanel", 
%         "SuperclassPanel", "AttributePanel", "DatasetPanel",
%         "LinkPanel", "GroupNamePanel", "InheritedMethodsPanel"
% Dropdowns: "GroupNameDropdown", "EntityTypeDropdown", "SuperclassDropdown"
% ListBoxes: "DatasetListBox", "LinkListBox", "AttributeListBox"
% EditBoxes: "ClassName", "FilePath", "DefaultGroupName"

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties
        MODEL 
    end

    methods (TestClassSetup)
        function MakeBaseModel(testCase)
            testCase.MODEL = aod.app.creator.CustomSubclass();
            testCase.MODEL.ClassName = "DeviceSubclass";
            testCase.MODEL.FilePath = pwd;
            testCase.MODEL.EntityType = 'Device';
            testCase.MODEL.SuperClass = "aod.core.Device";
        end

        function DeleteFiles(testCase) %#ok<MANU> 
            % Delete test files created from a prior run
            if exist('DeviceSubclass.m', 'file')
                delete('DeviceSubclass.m');
            end
        end
    end

    % Support methods
    methods 
        function model = getBaseModel(testCase)
            model = testCase.MODEL;
            model.clearDatasets(); 
            model.clearAttributes();
            model.clearLinks();
        end

        function closeApp(~, appHandle)
            appHandle.stop();
        end
    end

    methods (Test, TestTags=["Model"])
        function CustomSubclass(testCase)
            M = aod.app.creator.CustomSubclass('MyNewClass');
            testCase.verifyEqual(M.ClassName, "MyNewClass");

            D1 = aod.util.templates.PropertySpecification('Dset1');
            D2 = aod.util.templates.PropertySpecification('Dset2');
            D3 = aod.util.templates.PropertySpecification('Dset3');

            M.addDataset([D1 D2]);
            M.addDataset(D3);
            [out, idx] = M.getDataset('Dset2');
            testCase.verifyEqual(out.Name, D2.Name);
            testCase.verifyEqual(idx, 2);
            testCase.verifyEmpty(M.hasSetMethod());
        end
    end

    methods (Test, TestTags=["Controller", "CustomSubclass"])
        function AppOpenClose(testCase)
            [model, app] = AODataSubclassCreator();
            app.show();

            testCase.verifyFalse(model.isWriteable);
            testCase.verifyFalse(model.isViewable);

            % Close out the app
            testCase.closeApp(app);
        end

        function SetName(testCase)
            [model, app] = AODataSubclassCreator();
            fig = app.getView();

            h = findByTag(fig, "ClassName");
            h.Value = "";
            testCase.type(h, "NewName");
            % Verify in the UI
            testCase.verifyTrue(strcmp(h.Value, 'NewName'));
            % Verify in the model
            testCase.verifyTrue(strcmp(model.ClassName, "NewName"));

            % Close out the app
            testCase.closeApp(app);
        end

        function InputNamePathEntity(testCase)
            model = aod.app.creator.CustomSubclass();
            model.ClassName = "Demo1";
            model.FilePath = pwd;
            model.EntityType = 'Device';

            app = aod.app.creator.CustomSubclassController(model);
            fig = app.getView();

            % Verify class name
            testCase.verifyTrue(strcmp(model.ClassName,... 
                app.titleBox.Text));
            testCase.verifyTrue(strcmp(model.ClassName, ...
                get(findByTag(fig, 'ClassName'), "Value")));
            % Verify file path
            testCase.verifyTrue(strcmp(model.FilePath,...
                get(findByTag(fig, 'FilePath'), "Value")));
            % Verify entity type
            testCase.verifyTrue(strcmp('Device',...
                get(findByTag(fig, 'EntityTypeDropdown'), 'Value')));
            % Verify superclasses are correct
            testCase.verifyTrue(ismember("aod.core.Device",...
                get(findByTag(fig, 'SuperclassDropdown'), "Items")));
            % Verify writeable and viewable
            testCase.verifyFalse(model.isWriteable);
            testCase.verifyFalse(model.isViewable);

            % Close out the app
            testCase.closeApp(app);
        end 

        function SetSuperclass(testCase)
            model = aod.app.creator.CustomSubclass();
            model.ClassName = "DeviceSubclass";
            model.FilePath = pwd;
            model.EntityType = 'Device';
            model.SuperClass = "aod.core.Device";

            app = aod.app.creator.CustomSubclassController(model);
            fig = app.getView();

            % Verify entity type
            testCase.verifyTrue(strcmp("aod.core.Device",...
                get(findByTag(fig, 'SuperclassDropdown'), 'Value')));
            
            % Verify writeable and viewable
            testCase.verifyTrue(model.isWriteable);
            testCase.verifyTrue(model.isViewable);
            
            % Try updating...
            updateButton = findByTag(fig, "UpdateButton");
            testCase.press(updateButton);

            % Check the output
            txt = app.codeEditor.Value;
            testCase.verifyTrue(any(contains(txt,...
                "classdef DeviceSubclass < aod.core.Device")));

            % Write the file
            testCase.press(findByTag(fig, "WriteButton"));

            % Close out the app
            testCase.closeApp(app);
        end
    end

    methods (Test, TestTags=["GroupName", "CustomSubclass"])
        function GroupNames(testCase)

            % Setup
            model = testCase.getBaseModel();
            app = aod.app.creator.CustomSubclassController(model);
            fig = app.getView();

            groupBox = findByTag(fig, "GroupNameDropdown");
            defaultNameBox = findByTag(fig, "DefaultGroupName");

            testCase.verifyEqual(defaultNameBox.Enable, ...
                matlab.lang.OnOffSwitchState('off'));
            
            % UserDefinedWithDefault
            testCase.choose(groupBox, "UserDefinedWithDefault");
            testCase.verifyEqual(defaultNameBox.Enable, ...
                matlab.lang.OnOffSwitchState('on'));
            testCase.type(defaultNameBox, "MyDefaultName");
            % Update the view
            testCase.press(findByTag(fig, "UpdateButton"));
            % Test written class
            testCase.verifyTrue(any(contains(app.codeEditor.Value,...
                'name = "MyDefaultName"')));

            % HardCoded
            testCase.choose(groupBox, "HardCoded");
            testCase.verifyEqual(defaultNameBox.Enable, ...
                matlab.lang.OnOffSwitchState('on'));
            testCase.type(defaultNameBox, "AnotherDefaultName");
            % Update the view
            testCase.press(findByTag(fig, "UpdateButton"));
            % Test written class
            testCase.verifyTrue(any(contains(app.codeEditor.Value,...
                'obj@aod.core.Device("AnotherDefaultName"')));
            testCase.verifyFalse(any(contains(app.codeEditor.Value,...
                'obj = DeviceSubclass(name, ')));

            % DefinedInternally
            testCase.choose(groupBox, "DefinedInternally");
            testCase.verifyEqual(defaultNameBox.Enable, ...
                matlab.lang.OnOffSwitchState('off'));
            % Update the view
            testCase.press(findByTag(fig, "UpdateButton"));
            % Test written class
            testCase.verifyTrue(any(contains(app.codeEditor.Value,...
                'value = getLabel(obj)')));
            testCase.verifyTrue(any(contains(app.codeEditor.Value,...
                'obj@aod.core.Device([], ')));
            
            % ClassName
            testCase.choose(groupBox, "ClassName");
            testCase.verifyEqual(defaultNameBox.Enable, ...
                matlab.lang.OnOffSwitchState('off'));
            % Update the view
            testCase.press(findByTag(fig, "UpdateButton"));
            % Test written class
            testCase.verifyTrue(any(contains(app.codeEditor.Value,...
                'obj@aod.core.Device([], ')));
            testCase.verifyFalse(any(contains(app.codeEditor.Value,...
                'value = getLabel(obj)')));
            testCase.verifyFalse(any(contains(app.codeEditor.Value,...
                'obj = DeviceSubclass(name, ')));

            % Close out the app
            testCase.closeApp(app);

        end
    end

    methods (Test, TestTags=["Datasets", "CustomSubclass"])
        function ModelAddDataset(testCase)

            % Setup
            model = testCase.getBaseModel();
            app = aod.app.creator.CustomSubclassController(model);
            fig = app.getView();

            prop = aod.util.templates.PropertySpecification('Prop1');
            % Test mutually-exclusive relationship b/w required & optional
            prop.isOptional = true;
            prop.isRequired = true;
            testCase.verifyFalse(prop.isOptional);
            testCase.verifyTrue(prop.isRequired);

            model.addDataset(prop);

            h = findByTag(fig, "DatasetListBox");
            testCase.verifyTrue(ismember("Prop1", h.Items));

            % Update the view
            testCase.press(findByTag(fig, "UpdateButton"));

            % Check for properties block
            testCase.verifyTrue(any(contains(app.codeEditor.Value,...
            "properties")));

            % Check for required assignment
            testCase.verifyTrue(any(contains(app.codeEditor.Value,...
                "obj.Prop1 = prop1;")));

            model.clearDatasets();
            testCase.verifyEqual(h.Items, {char.empty()});

            % Close out the app
            testCase.closeApp(app);
        end 

        function DatasetSpecification1(testCase)
            % Test required properties with description and makeFcn
            model = testCase.getBaseModel();
            app = aod.app.creator.CustomSubclassController(model);
            fig = app.getView();

            % Create a required property w/ a set function
            prop1 = aod.util.templates.PropertySpecification('Prop1');
            prop1.makeSetFcn = true;
            prop1.isRequired = true;
            prop1.Description = "The first property";

            model.addDataset(prop1);

            % Update the view
            testCase.press(findByTag(fig, "UpdateButton"));
            % Check description
            testCase.verifyTrue(any(contains(app.codeEditor.Value,... 
                "% The first property")));
            % Test makeFcn
            testCase.verifyTrue(any(contains(app.codeEditor.Value,...
                "function setProp1(obj, ")));
            % Test assignment
            testCase.verifyTrue(any(contains(app.codeEditor.Value,...
                "obj.setProp1(prop1);")));

            model.clearDatasets();
            % Close out the app
            testCase.closeApp(app);
        end

        function DatasetSpecification2(testCase)
            % Test optional properties with default & validation
            model = testCase.getBaseModel();
            app = aod.app.creator.CustomSubclassController(model);
            fig = app.getView();

            % Create an optional property with default + validation
            prop = aod.util.templates.PropertySpecification('Prop2');
            prop.Validation = {@mustBeNumeric};
            prop.Default = 123;
            prop.isOptional = true;

            model.addDataset(prop);

            % Update the view
            testCase.press(findByTag(fig, "UpdateButton"));
            % Check optional arg input parser
            testCase.verifyTrue(any(contains(app.codeEditor.Value,...
                "ip = aod.util.InputParser")));
            % Ensure default value is included
            testCase.verifyTrue(any(contains(app.codeEditor.Value,...
                "addParameter(ip, 'Prop2', 123")));
            % Test validation in prop definition
            testCase.verifyTrue(any(contains(app.codeEditor.Value,...
                "{mustBeNumeric")));
            % Test default in prop definition
            testCase.verifyTrue(any(contains(app.codeEditor.Value,...
                "= 123")));

            % Close out the app
            testCase.closeApp(app);
        end
    end

    methods (Test, TestTags=["Links", "CustomSubclass"])
        function LinkSpecification(testCase)
            model = aod.app.creator.CustomSubclass();
            model.ClassName = "AnnotationSubclass";
            model.FilePath = pwd;
            model.EntityType = 'Annotation';
            model.SuperClass = "aod.core.Annotation";
            app = aod.app.creator.CustomSubclassController(model);
            fig = app.getView();

            % Create a link to a Source
            prop1 = aod.util.templates.LinkSpecification('Link1', 'Source');
            prop1.isOptional = true;
            prop1.makeSetFcn = true;
            prop1.Description = "A link to a source";

            model.addLink(prop1);

            % Update the view
            testCase.press(findByTag(fig, "UpdateButton"));

            % Check the property block
            testCase.verifyTrue(any(contains(app.codeEditor.Value,... 
                "% A link to a source")));
            testCase.verifyTrue(any(contains(app.codeEditor.Value,...
                "= aod.core.Source.empty()")));
            testCase.verifyTrue(any(contains(app.codeEditor.Value,...
                "mustBeEntityType")));
            % Check optional arg input parser
            testCase.verifyTrue(any(contains(app.codeEditor.Value,...
                "ip = aod.util.InputParser")));
            % Check for set fcn
            testCase.verifyTrue(any(contains(app.codeEditor.Value,...
                "function setLink1(obj,")));

            % Remove the links
            model.clearLinks();

            % Close out the app
            testCase.closeApp(app);
        end

        function ModelAddLink(testCase)
            % Setup
            model = aod.app.creator.CustomSubclass();
            model.ClassName = "SystemSubclass";
            model.FilePath = pwd;
            model.EntityType = 'System';
            model.SuperClass = "aod.core.System";
            app = aod.app.creator.CustomSubclassController(model);
            fig = app.getView();

            prop = aod.util.templates.LinkSpecification('Link1', 'Source');

            model.addLink(prop);

            linkBox = findByTag(fig, "LinkListBox");
            testCase.verifyTrue(ismember("Link1", linkBox.Items));

            model.clearLinks();
            testCase.verifyEqual(linkBox.Items, {char.empty()});

            % Add the link again and remove from the UI
            prop = aod.util.templates.LinkSpecification('Link1', 'Source');
            model.addLink(prop);
            % Select the new link and remove it
            testCase.choose(findobj(fig, 'Type', 'uitabgroup'), 2);
            testCase.choose(linkBox, 'Link1');
            app.onPushRemoveLink();
            testCase.verifyEqual(linkBox.Items, {char.empty()});

            % Close out the app
            app.delete();
        end
    end

    methods (Test, TestTags=["Attributes", "CustomSubclass"])
        function AttributeSpecification(testCase)
            
            model = aod.app.creator.CustomSubclass();
            model.ClassName = "ChannelSubclass";
            model.FilePath = pwd;
            model.EntityType = 'Channel';
            model.SuperClass = "aod.core.Channel";

            app = aod.app.creator.CustomSubclassController(model);
            fig = app.getView();

            % Attribute with a set function and description
            attr1 = aod.util.templates.AttributeSpecification('Attr1');
            attr1.makeSetFcn = true;
            attr1.Description = "The first attribute";
            model.addAttribute(attr1);

            % Attribute with default, validation and a set fcn
            attr2 = aod.util.templates.AttributeSpecification('Attr2');
            attr2.Default = 123;
            attr2.Validation = {@isnumeric};
            attr2.makeSetFcn = true;
            model.addAttribute(attr2);

            % Ensure both are present in the listbox
            attrBox = findByTag(fig, "AttributeListBox");
            testCase.verifyNumElements(attrBox.Items, 2);
            
            % Update the view
            testCase.press(findByTag(fig, "UpdateButton"));

            % Confirm expected attribute box is present
            testCase.verifyTrue(any(contains(app.codeEditor.Value,...
                "value = specifyAttributes@aod.core.Channel()")));
            % Verify attribute expecification
            testCase.verifyTrue(any(contains(app.codeEditor.Value,...
                "value.add('Attr1', [], [],"))); % has description
            testCase.verifyTrue(any(contains(app.codeEditor.Value,...
                "value.add('Attr2', 123, @isnumeric);"))); 
            % Verify set functions
            testCase.verifyTrue(any(contains(app.codeEditor.Value,...
                "obj.setAttr('Attr1', value);")));
            testCase.verifyTrue(any(contains(app.codeEditor.Value,...
                "obj.setAttr('Attr2', value);")));
            % Verify documentation
            testCase.verifyTrue(any(contains(app.codeEditor.Value,...
                "% Attributes:")));
            testCase.verifyTrue(any(contains(app.codeEditor.Value,...
                "(default = 123)")));
            
            % Close out the app
            app.delete();
        end

        function ModelAddAttribute(testCase)
        
            model = aod.app.creator.CustomSubclass();
            model.ClassName = "ChannelSubclass";
            model.FilePath = pwd;
            model.EntityType = 'Channel';
            model.SuperClass = "aod.core.Channel";

            app = aod.app.creator.CustomSubclassController(model);
            fig = app.getView();

            prop = aod.util.templates.AttributeSpecification('Attr1');
            model.addAttribute(prop);

            attrBox = findByTag(fig, "AttributeListBox");
            testCase.verifyTrue(ismember("Attr1", attrBox.Items));

            % Change tabs
            testCase.choose(findobj(fig, 'Type', 'uitabgroup'), 2);

            % Remove the attribute
            testCase.choose(attrBox, 'Attr1');
            app.onPushRemoveAttribute();
            testCase.verifyEqual(attrBox.Items, {char.empty()});

            % Close out the app
            app.delete();
        end
    end
end 