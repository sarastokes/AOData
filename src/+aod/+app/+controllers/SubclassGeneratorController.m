classdef SubclassGeneratorController < aod.app.Controller
% Controller for subclass generation ui
%
% Parent:
%   aod.app.Controller
%
% Constructor:
%   obj = aod.app.controllers.SubclassGeneratorController(model)
%
% See also:
%   aod.app.models.SubclassGenerator, aod.app.views.SubclassWriter

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties %(SetAccess = private)
        methodListBox
        detailBox
        titleBox
        helpBox
    end

    properties (Hidden, Constant)
        LAYOUT_PROPS = {"Padding", 5,... 
            "RowSpacing", 5, "ColumnSpacing", 5};
        ICON_DIR = fullfile(getpref('AOData', 'BasePackage'),... 
            'src', '+aod', '+app', '+icons');
    end

    methods
        function obj = SubclassGeneratorController(model)
            arguments
                model   {mustBeA(model, "aod.app.models.SubclassGenerator")} = SubclassGenerator();
            end
            
            obj@aod.app.Controller(model);
        end

        function m = getModel(obj)
            % For debugging but may be worth keeping around for times when 
            % Model isn't explicitly created before Controller
            m = obj.Model;
        end

        function v = getView(obj)
            % Access to the figure for test suites
            v = obj.figureHandle;
        end
    end

    methods (Access = protected)
        function bind(obj)
            m = obj.Model;
            obj.addListener(m, 'ChangedDatasets', @obj.onModelChangedDatasets);
            obj.addListener(m, 'ChangedLinks', @obj.onModelChangedLinks);
            obj.addListener(m, 'ChangedAttributes', @obj.onModelChangedAttributes);
        end

        function willGo(obj)
            if ~isempty(obj.Model.ClassName)
                obj.didSetClassName(true);
            end
            if ~isempty(obj.Model.FilePath)
                obj.setFilePath(obj.Model.FilePath);
            end

            set(findByTag(obj.figureHandle, "EntityTypeDropdown"),...
                "Items", [""; obj.Model.getAllowableEntityTypes()]);
            if ~isempty(obj.Model.EntityType)
                obj.didSetEntityType(true);
            end

            if ~isempty(obj.Model.SuperClass)
                obj.didSetSuperClass(true);
            end

            set(findByTag(obj.figureHandle, "GroupNameDropdown"),...
                "Items", string(enumeration('aod.app.GroupNameType')));
            if ~isempty(obj.Model.groupNameMode)
                obj.didSetGroupNameMode(true);
            end

            if ~isempty(obj.Model.Datasets)
                obj.onModelChangedDatasets();
            end

            if ~isempty(obj.Model.Links)
                obj.onModelChangedLinks();
            end

            if ~isempty(obj.Model.Attributes)
                obj.onModelChangedAttributes();
            end
        end
    end 
    
    methods 
        function update(obj)
            if obj.Model.isViewable
                set(findByTag(obj.figureHandle, "UpdateButton"),...
                    "Enable", "on");
            end

            if obj.Model.isWriteable
                set(findByTag(obj.figureHandle, "WriteButton"),...
                    "Enable", "on");
            end
            update@aod.app.Controller(obj);
        end
    end

    % Support methods
    methods
        function [success, ME] = trySetModel(obj, propName, propValue)
            % Try to set Model property, collects errors if fails 
            %
            % Description:
            %   Tries to set Model property and collects any errors that 
            %   are thrown by Model's set function parsing. The calling 
            %   function then has the option of handling the error to 
            %   ensure it doesn't halt functionality of the UI for user.
            %   Because the Model's set functions handle all argument 
            %   validation, errors are expected to be relatively common
            %
            % Syntax:
            %   [success, ME] = trySetModel(obj, propName, propValue)
            % -------------------------------------------------------------

            try
                obj.Model.(propName) = propValue;
                success = true;
                ME = [];
            catch ME 
                success = false;
            end
        end

        function out = getIcon(obj, iconName)
            out = fullfile(obj.ICON_DIR, iconName);
        end
    end

    % Listener callbacks
    methods
        function onModelChangedDatasets(obj, ~, ~)
            if isempty(obj.Model.Datasets)
                out = "";
            else
                out = arrayfun(@(x) x.Name, obj.Model.Datasets);
            end
            h = findByTag(obj.figureHandle, "DatasetListBox");
            set(h, "Items", out);
        end

        function onModelChangedLinks(obj, ~, ~)
            if isempty(obj.Model.Links)
                out = "";
            else
                out = arrayfun(@(x) x.Name, obj.Model.Links);
            end
            h = findByTag(obj.figureHandle, "LinkListBox");
            set(h, "Items", out);
        end

        function onModelChangedAttributes(obj, ~, ~)
            if isempty(obj.Model.Attributes)
                out = "";
            else
                out = arrayfun(@(x) x.Name, obj.Model.Attributes);
            end
            h = findByTag(obj.figureHandle, "AttributeListBox");
            set(h, "Items", out);
        end
    end

    % UI callbacks
    methods %(Access = private)
        function onClassNameChanged(obj, src, evt)
            % ONCLASSNAMECHANGED
            [success, ME] = obj.trySetModel('ClassName', evt.Value);
            if success
                src.BackgroundColor = [0.95 1 0.98];
                obj.didSetClassName(false);
            else
                src.BackgroundColor = [1 0.7 0.7];
                obj.showError(ME.message);
                warning(ME.identifier, ME.message);
            end
        end

        function didSetClassName(obj, setValueFlag)
            % DIDSETCLASSNAME
            if setValueFlag
                set(findByTag(obj.figureHandle, "ClassName"),...
                    "Value", obj.Model.ClassName);
            end
            set(obj.titleBox, "Text", obj.Model.classNameWithPackages);
            obj.update();
        end

        function onPushFileBrowser(obj, ~, ~)
            % ONPUSHFILEBROWSER
            filePath = obj.showGetDirectory('Choose a location for the new class');
            if isempty(filePath)
                filePath = [];
            end
            
            [success, ME] = obj.trySetModel('FilePath', filePath);
            if success
                obj.setFilePath(filePath);
            else
                obj.showError(ME.message);
                warning(ME.identifier, ME.message);
            end
        end

        function setFilePath(obj, value)
            % SETFILEPATH
            set(findByTag(obj.figureHandle, "FilePath"),...
                "Value", value);
            set(obj.titleBox, "Text", obj.Model.classNameWithPackages);
            obj.update();
        end

        function onEntityTypeSelected(obj, ~, evt)
            % ONENTITYTYPESELECTED
            if evt.Value == ""
                return
            end

            [success, ME] = obj.trySetModel('EntityType', evt.Value);
            if success
                obj.didSetEntityType(false);
            else
                obj.showError(ME.message);
                warning(ME.identifier, ME.message);
            end
        end

        function didSetEntityType(obj, setValueFlag)
            % DIDSETENTITYTYPE
            if setValueFlag
                set(findByTag(obj.figureHandle, "EntityTypeDropdown"),...
                    "Value", appbox.capitalize(char(obj.Model.EntityType)));
            end
            set(findByTag(obj.figureHandle, "SuperclassPanel"), 'Visible', 'on');
            set(findByTag(obj.figureHandle, "SuperclassDropdown"),...
                "Items", [""; obj.Model.getAllowableSuperclasses()]);
            obj.update();
        end

        function onSuperclassSelected(obj, ~, evt)
            % ONSUPERCLASSSELECTED
            if evt.Value == ""
                return
            end
            [success, ME] = obj.trySetModel('SuperClass', evt.Value);
            if success 
                obj.didSetSuperClass(false);
            else
                obj.showError(ME.message);
                warning(ME.identifier, ME.message);
            end
        end

        function didSetSuperClass(obj, setValueFlag)
            % DIDSETSUPERCLASS
            if setValueFlag
                set(findByTag(obj.figureHandle, "SuperclassDropdown"),...
                    "Value", obj.Model.SuperClass);
            end
            T = obj.Model.getAllowableMethods();
            set(findByTag(obj.figureHandle, "OverloadedMethods"),...
                "Enable", "on", "Items", [""; T.Name]);
            set(findByTag(obj.figureHandle, "OverwrittenMethods"),...
                "Enable", "on", "Items", [""; T.Name]);
            obj.update();
        end

        function onSelectedGroupNameMode(obj, ~, evt)
            % ONSELECTEDGROUPNAMEMODE
            [success, ME] = obj.trySetModel('groupNameMode', evt.Value);
            if success
                obj.didSetGroupNameMode(false)
            else
                obj.showError(ME.message);
                warning(ME.identifier, ME.message);
            end
        end

        function didSetGroupNameMode(obj, setValueFlag)
            % DIDSETGROUPNAMEMODE
            if setValueFlag
                set(findByTag(obj.figureHandle, "GroupNameDropdown"),...
                    "Value", obj.Model.groupNameMode);
            end
            if ismember(obj.Model.groupNameMode, ["HardCoded", "UserDefinedWithDefault"])
                set(findByTag(obj.figureHandle, "DefaultGroupName"),...
                    "Enable", true, "Value", obj.Model.defaultName);
            else
                set(findByTag(obj.figureHandle, "DefaultGroupName"),...
                    "Enable", false);
            end
        end

        function onSetDefaultName(obj, ~, evt)
            % ONSETDEFAULTNAME
            [success, ME] = obj.trySetModel('defaultName', evt.Value);
            if ~success
                obj.showError(ME.message);
                warning(ME.identifier, ME.message);
            end
        end

        function onPushAddDataset(obj, ~, ~)
            out = inputdlg('What is the dataset name?',... 
                'New Dataset', [1 35], "DatasetName");

            if isempty(out)
                return
            end

            prop = aod.util.templates.PropertySpecification(out);
            obj.Model.addDataset(prop);
            inspect(obj.Model.Datasets(end));
        end

        function onPushRemoveDataset(obj, ~, ~)
            h = findByTag(obj.figureHandle, "DatasetListBox");
            if isempty(h.Items) || isempty(h.Value)
                return 
            end
            out = h.Value;
            obj.Model.removeDataset(out);
        end

        function onPushEditDataset(obj, ~, ~)
            h = findByTag(obj.figureHandle, "DatasetListBox");
            prop = obj.Model.getDataset(h.Value);
            inspect(prop);
        end

        function onPushAddAttribute(obj, ~, ~)
            out = inputdlg('What is the parameter name?',... 
                'New Parameter UI', [1 35], "MyParam");

            if isempty(out)
                return
            end

            attr = aod.util.templates.AttributeSpecification(out);
            obj.Model.addAttribute(attr);
            inspect(obj.Model.Attributes(end));
        end
        
        function onPushRemoveAttribute(obj, ~, ~)
            h = findByTag(obj.figureHandle, "AttributeListBox");
            if isempty(h.Items) || isempty(h.Value)
                return 
            end
            out = h.Value;
            obj.Model.removeAttribute(out);
        end

        function onPushAddLink(obj, ~, ~)
            out = inputdlg(...
                {'What is the link name?', 'Which Entity Type(s) are allowed? If more than one, separate with commas'},...
                'New Link', [1 35], {'MyLink', 'Device, Channel'});

            if isempty(out)
                return
            end

            link = aod.util.templates.LinkSpecification(out{1}, out{2});
            obj.Model.addLink(link);
            inspect(obj.Model.Links(end));
        end

        function onPushRemoveLink(obj, ~, ~)
            h = findByTag(obj.figureHandle, "LinkListBox");
            if numel(h.Items) == 0 || isempty(h.Value)
                return
            end
            out = h.Value;
            obj.Model.removeLink(out);
        end

        function onChangedOverloadedMethods(obj, ~, evt)
            methodList = string(evt.Value)';
            [success, ME] = obj.trySetModel('overloadedMethods', methodList);
            if success
                % TODO Did set method
            else
                obj.showError(ME.message);
                warning(ME.identifier, ME.message);
            end
        end

        function onChangedOverwrittenMethods(obj, ~, evt)    
            % ONCHANGEDOVERWRITTENMETHODS        
            methodList = string(evt.Value)';
            [success, ME] = obj.trySetModel('overwrittenMethods', methodList);
            if success
                % TODO: Did set method
            else
                obj.showError(ME.message);
                warning(ME.identifier, ME.message);
            end
        end

        function onMenuChangeFont(obj, ~, ~)
            uisetfont(obj.detailBox);
        end

        function onMenuIncreaseFontSize(obj, ~, ~)
            fontsize(obj.detailBox, "increase");
        end

        function onMenuDecreaseFontSize(obj, ~, ~)
            fontsize(obj.detailBox, "decrease");
        end

        function onPushUpdate(obj, ~, ~)
            % ONPUSHUPDATE
            if ~obj.Model.isViewable
                return
            end
            set(obj.detailBox, "Value", "");
            obj.update();
            writer = aod.app.views.SubclassWriter(obj.Model);
            out = writer.getFull();
            set(obj.detailBox, "Value", out);
            obj.update();
        end

        function onPushWrite(obj, ~, ~)
            writer = aod.app.views.SubclassWriter(obj.Model);
            writer.write();
        end

        function onGetHelp(obj, src, ~)
            switch src.Tag 
                case "ClassNamePanel"
                    obj.helpBox.Value = "What will your class be named?";
                case "EntityTypePanel"
                    obj.helpBox.Value = ...
                        "Which AOData entity type should the new class be?";
                case "SuperclassPanel"
                    obj.helpBox.Value = "Choose a superclass. " + ... 
                        "The entity will inherit properties and methods " +...
                        "from this class";
                case "GroupNamePanel"
                    obj.helpBox.Value = ...
                        "How will the entity's HDF5 group name be determined?";
            end
        end
    end

    methods
        function obj = createUi(obj)
            % Default uigridlayout properties
            
            % Center the UI on the screen and name
            obj.figureHandle.Position(3:4) = [1.5 1.3] .* obj.figureHandle.Position(3:4);
            movegui(obj.figureHandle, "center");
            obj.figureHandle.Name = "Subclass Generator";

            mainLayout = uigridlayout(obj.figureHandle, [4 2],...
                "RowHeight", {'fit', '2x', 'fit', '0.15x'},...
                "ColumnWidth", {'1x', '1x'},...
                "RowSpacing", 3);
            
            % Title
            obj.titleBox = uilabel(mainLayout,...
                "Text", "   ", "HorizontalAlignment", "center",...
                "FontWeight", "bold");
            obj.setLayout(obj.titleBox, 1, 1);

            % UI Controls
            uiTabGroup = uitabgroup(mainLayout);
            obj.setLayout(uiTabGroup, 2, 1);

            % Basic Tab
            basicTab = uitab(uiTabGroup, "Title", "Basic");
            basicGrid = uigridlayout(basicTab, [3 6],...
                "RowHeight", {70, 70, 70}, obj.LAYOUT_PROPS{:});

            % Detail Tab
            detailTab = uitab(uiTabGroup, "Title", "Details");
            detailGrid = uigridlayout(detailTab, [1 3], obj.LAYOUT_PROPS{:});

            % Advanced Tab
            advTab = uitab(uiTabGroup, "Title", "Advanced");
            advGrid = uigridlayout(advTab, [1 1], obj.LAYOUT_PROPS{:});

            % Documentation box
            h = uilabel(mainLayout, "Text", "Documentation:",...
                "VerticalAlignment", "bottom");
            obj.setLayout(h, 3, 1);

            obj.helpBox = uitextarea(mainLayout,...
                "Value", "Click on a panel for more information.");
            obj.setLayout(obj.helpBox, 4, 1);

            % Details
            p = uipanel(mainLayout, "Title", "Details",...
                "Tag", "DetailPanel", "FontSize", 12);
            obj.setLayout(p, [1 3], 2);
            obj.makeDetailBox(p);
            
            % SPECIFICATION --------------------------------------
            % What should the entity be named?
            % > uieditfield (#1)
            p = uipanel(basicGrid, "Title", "Class Name",...
                "FontSize", 12, "Tag", "ClassNamePanel",...
                "ButtonDownFcn", @obj.onGetHelp);
            obj.setLayout(p, 1, [1 3]);
            uieditfield(uigridlayout(p, [1 1], obj.LAYOUT_PROPS{:}),... 
                "Value", "",...
                "Tag", "ClassName",...
                "ValueChangedFcn", @obj.onClassNameChanged);

            % Where will the entity be saved?
            % > uigetdir (#2), check file conflicts
            p = uipanel(basicGrid, "Title", "File Path",...
                "FontSize", 12, "Tag", "FilePathPanel",...
                "ButtonDownFcn", @obj.onGetHelp);
            obj.setLayout(p, 1, [4 6]);
            obj.makeFilePathPanel(p);

            % Which EntityType?
            % > uidropdown (#3)
            p = uipanel(basicGrid, "Title", "Entity Type",...
                "FontSize", 12, "Tag", "EntityTypePanel",...
                "ButtonDownFcn", @obj.onGetHelp);
            obj.setLayout(p, 2, [1 3]);
            uidropdown(uigridlayout(p, [1 1], obj.LAYOUT_PROPS{:}),...
                "ValueChangedFcn", @obj.onEntityTypeSelected,...
                "Tag", "EntityTypeDropdown");           
            
            % What is the superclass?
            % > uidropdown (#4) based on entityType, then show inherited
            p = uipanel(basicGrid, "Title", "Superclass",...
                "FontSize", 12, "Tag", "SuperclassPanel",...
                "ButtonDownFcn", @obj.onGetHelp);
            obj.setLayout(p, 2, [4 6]);
            uidropdown(uigridlayout(p, [1 1], obj.LAYOUT_PROPS{:}),...
                "Items", "", "Tag", "SuperclassDropdown",...
                "ValueChangedFcn", @obj.onSuperclassSelected);

            % What attributes are expected?
            % - Required: Name 
            %   > uieditbox
            % - Optional: default, validation
            %   > uieditbox, uieditbox
            % - Optional: importance - required, optional or N/A
            %   > uidropdown (default N/A)
            p = uipanel(detailGrid, "Title", "Attributes",...
                "FontSize", 12, "FontWeight", "bold",... 
                "Tag", "AttributePanel",...
                "ButtonDownFcn", @obj.onGetHelp);
            obj.setLayout(p, 1, 1);
            obj.makeAttributePanel(p);

            % What datasets should the entity have (properties)?
            % - Required: name
            %   > uieditfield
            % - Optional: class, default
            %   > uieditfield, uieditfield
            % - Optional: Property's importance - required, optional or N/A
            %   > uidropdown (default N/A)
            p = uipanel(detailGrid, "Title", "Datasets",...
                "FontSize", 12, "FontWeight", "bold",... 
                "Tag", "DatasetPanel",...
                "ButtonDownFcn", @obj.onGetHelp);
            obj.setLayout(p, 1, 2);
            obj.makeDatasetPanel(p);

            % What links should the entity have (properties)?
            % - Required: Name 
            %   > uieditfield
            % - Optional: entityType(s)
            %   > uidropdown (excluding Experiment, Parent & EntityType)
            p = uipanel(detailGrid, "Title", "Links",...
                "FontSize", 12, "FontWeight", "bold",...
                "Tag", "LinkPanel",...
                "ButtonDownFcn", @obj.onGetHelp);
            obj.setLayout(p, 1, 3);
            obj.makeLinkPanel(p);

            % How should the entity's group name be determined?
            % - User-defined?
            %   > uicheckbox (isRequired)
            % - Hard-coded default? Could still be changed with setName
            %   - What is the default?
            %   > uicheckbox, uieditfield if true
            % - Automated based on properties/attributes?
            %   - Remove name input to constructor?
            p = uipanel(basicGrid, "Title", "Group Name",...
                "FontSize", 12, "Tag", "GroupNamePanel",...
                "ButtonDownFcn", @obj.onGetHelp);
            obj.setLayout(p, 3, [1 6]);
            obj.makeEntityGroupNamePanel(p);

            % Any specifications on inherited methods?
            p = uipanel(advGrid, "Title", "Inherited Methods",...
                "FontSize", 12, "Tag", "InheritedMethodsPanel",...
                "ButtonDownFcn", @obj.onGetHelp);
            obj.setLayout(p, [4 5], 1);
            obj.makeMethodPanel(p);
        end
    end

    methods (Access = private)
        function makeDetailBox(obj, p)
            g = uigridlayout(p, [2 2],...
                "RowHeight", {'1x', 'fit'}, obj.LAYOUT_PROPS{:});
            obj.detailBox = uitextarea(g, ...
                "FontSize", 10, "HorizontalAlignment", "left",...
                "FontName", "Consolas", "Editable", "off");
            obj.setLayout(obj.detailBox, 1, [1 2]);
            h = uibutton(g, "Text", "Update",...
                "Icon", obj.getIcon('icons8-refresh-40.png'),...
                "Enable", "off", "Tag", "UpdateButton",...
                "ButtonPushedFcn", @obj.onPushUpdate);
            obj.setLayout(h, 2, 1);
            h = uibutton(g, "Text", "Write",...
                "Icon", obj.getIcon('icons8-making-notes-40.png'),...
                "Enable", "off", "Tag", "WriteButton",...
                "ButtonPushedFcn", @obj.onPushWrite);
            obj.setLayout(h, 2, 2);

            % Add a context menu to change font
            cm = uicontextmenu(obj.figureHandle);
            uimenu(cm, "Text", "Change Font",...
                "MenuSelectedFcn", @obj.onMenuChangeFont);
            uimenu(cm, "Text", "Increase FontSize",...
                "MenuSelectedFcn", @obj.onMenuIncreaseFontSize);
            uimenu(cm, "Text", "Decrease FontSize",...
                "MenuSelectedFcn", @obj.onMenuDecreaseFontSize);
            obj.detailBox.ContextMenu = cm;
        end

        function makeFilePathPanel(obj, p)
            g = uigridlayout(p, [1 2], ...
                "ColumnWidth", {'fit', '4x'}, "Padding", 3);
            uibutton(g, "Text", "",...
                "Icon", obj.getIcon('filecabinet.png'),...
                "Tag", "FileBrowserButton",...
                "ButtonPushedFcn", @obj.onPushFileBrowser);
            uitextarea(g, "Value", "",... 
                "Tag", "FilePath", "Editable", "off");
        end

        function makeEntityGroupNamePanel(obj, p)
            g = uigridlayout(p, [2 2], obj.LAYOUT_PROPS{:});
            h = uidropdown(g,...
                "Tag", "GroupNameDropdown",...
                "ValueChangedFcn", @obj.onSelectedGroupNameMode);
            obj.setLayout(h, [1 2], 1);

            h = uilabel(g,...
                "Text", "Default Entity Name:",...
                "HorizontalAlignment", "left");
            obj.setLayout(h, 1, 2);
            h = uieditfield(g,...
                "Tag", "DefaultGroupName",...
                "ValueChangedFcn", @obj.onSetDefaultName);
            obj.setLayout(h, 2, 2);
        end

        function [h1, h2, h3] = makeButtons(obj, g)
            h1 = uibutton(g, "Text", "Add",...
                "Icon", obj.getIcon('icons8-add-40.png'));
            obj.setLayout(h1, 1, 1);
            h2 = uibutton(g, "Text", "Remove",...
                "Icon", obj.getIcon('icons8-do-not-disturb-40.png'));
            obj.setLayout(h2, 2, 1);
            h3 = uibutton(g, "Text", "Edit",...
                "Icon", obj.getIcon('icons8-edit-40.png'));
            obj.setLayout(h3, 3, 1);
        end

        function makeAttributePanel(obj, p)
            g = uigridlayout(p, [2 1],...
                "RowHeight", {'1x', 'fit'}, obj.LAYOUT_PROPS{:});
            h = uilistbox(g, "Items", "", "Tag", "AttributeListBox");
            obj.setLayout(h, 1, 1);
            g2 = uigridlayout(g, [3 1], obj.LAYOUT_PROPS{:});
            obj.setLayout(g2, 2, 1);
            [h1, h2, h3] = obj.makeButtons(g2);
            set(h1, "Tag", "AddAttributeButton",...
                "ButtonPushedFcn", @obj.onPushAddAttribute);
            set(h2, "Tag", "RemoveAttributeButton",...
                "ButtonPushedFcn", @obj.onPushRemoveAttribute);
            set(h3, "Tag", "EditAttributeButton");
        end

        function makeDatasetPanel(obj, p)
            g = uigridlayout(p, [2 1],...
                "RowHeight", {'1x', 'fit'}, obj.LAYOUT_PROPS{:});
            h = uilistbox(g, "Items", "", "Tag", "DatasetListBox");
            obj.setLayout(h, 1, 1);
            g2 = uigridlayout(g, [3 1], obj.LAYOUT_PROPS{:});
            obj.setLayout(g2, 2, 1);
            [h1, h2, h3] = obj.makeButtons(g2);
            set(h1, "Tag", "AddDatasetButton",...
                "ButtonPushedFcn", @obj.onPushAddDataset);
            set(h2, "Tag", "RemoveDatasetButton",...
                "ButtonPushedFcn", @obj.onPushRemoveDataset);
            set(h3, "Tag", "EditDatasetButton");
        end

        function makeLinkPanel(obj, p)
            g = uigridlayout(p, [2 1],...
                "RowHeight", {'1x', 'fit'}, obj.LAYOUT_PROPS{:});
            h = uilistbox(g, "Items", "", "Tag", "LinkListBox");
            obj.setLayout(h, 1, 1);
            g2 = uigridlayout(g, [3 1], obj.LAYOUT_PROPS{:});
            obj.setLayout(g2, 2, 1);
            [h1, h2, h3] = obj.makeButtons(g2);
            set(h1, "Tag", "AddLinkButton",...
                "ButtonPushedFcn", @obj.onPushAddLink);
            set(h2, "Tag", "RemoveLinkButton",...
                "ButtonPushedFcn", @obj.onPushRemoveLink);
            set(h3, "Tag", "EditLinkButton");
        end
        
        function makeMethodPanel(obj, p)
            g = uigridlayout(p, [4 3], obj.LAYOUT_PROPS{:},...
                "ColumnWidth", {"1x", 30, "1x"},...
                "RowHeight", {30, "1x", 30, "1x"});
            % - Overloaded methods?
            %   > uidropdown
            obj.methodListBox = uilistbox(g,...
                "Items", "", "Enable", "off",...
                "Tag", "InheritedMethods");
            obj.setLayout(obj.methodListBox, [1 4], 1);

            h = uilabel(g, "Text", "Overload");
            obj.setLayout(h, 3, 1);
            h = uilistbox(g,...
                "Items", "", "Multiselect", "on",... 
                "Enable", "off", "Tag", "OverloadedMethods",...
                "ValueChangedFcn", @obj.onChangedOverloadedMethods);
            obj.setLayout(h, 3, 1);

            % - Overwritten methods?
            %   > uidropdown
            h = uilabel(g, "Text", "Overwrite");
            obj.setLayout(h, 3, 3);
            h = uilistbox(g,...
                "Items", "", "Multiselect", "on",... 
                "Enable", "off", "Tag", "OverwrittenMethods",...
                "ValueChangedFcn", @obj.onChangedOverwrittenMethods);
            obj.setLayout(h, 3, 4);
        end
    end

    methods (Static)
        function setLayout(h, row, col)
            if ~isempty(row)
                h.Layout.Row = row;
            end

            if nargin > 2 && ~isempty(col)
                h.Layout.Column = col;
            end
        end
    end
end 