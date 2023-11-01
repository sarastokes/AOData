classdef SpecificationComparison < handle

    properties
        refSpec
        testSpec

        details
        keys                    string
        values

        testListbox             matlab.ui.control.ListBox
        refListbox              matlab.ui.control.ListBox
        actionButton            matlab.ui.control.Button

        sameField               matlab.ui.control.Label
        stagedField             matlab.ui.control.Label
        changedField            matlab.ui.control.Label
        unexpectedField         matlab.ui.control.Label
        missingField            matlab.ui.control.Label
    end

    properties (SetAccess = private)
        currentParam            char
        currentValue            char
        currentComparison
    end

    properties (Hidden, Constant)
        CHANGED = uistyle('BackgroundColor', hex2rgb('ADD3FF'));
        ADDED = uistyle('BackgroundColor', hex2rgb('A6F2C3'));
        REMOVED = uistyle('BackgroundColor', hex2rgb('FFD6DD'));
    end

    methods
        function obj = SpecificationComparison(testSpec, refSpec, parent)
            arguments
                testSpec        aod.specification.Entry
                refSpec         aod.specification.Entry
                parent          = []
            end

            obj.refSpec = refSpec;
            obj.testSpec = testSpec;

            obj.details = obj.refSpec.compare(obj.testSpec);
            obj.keys = vertcat(string(obj.details.keys));
            obj.values = unpackValues(obj.details);

            obj.createUi(parent);
        end
    end

    methods
        function onValueSelected(obj, ~, evt)
            param = strsplit(evt.Value, ' - ');
            obj.currentParam = param{1};
            obj.currentValue = erase(evt.Value, [param{1}, ' - ']);
            obj.currentComparison = obj.details(obj.currentParam);

            switch obj.currentComparison
                case aod.schema.MatchType.SAME
                    obj.actionButton.Text = "Specifications Match";
                    obj.actionButton.Visible = "off";
                case aod.schema.MatchType.CHANGED
                    set(obj.actionButton,...
                        "Text", "Set to Reference Value",...
                        "Visible", "on");
                case aod.schema.MatchType.REMOVED
                    set(obj.actionButton,...
                        "Text", "Set to Reference Value",...
                        "Visible", "on");
                case aod.schema.MatchType.CLEAR
                    set(obj.actionButton,...
                        "Text", "Clear Value",...
                        "Visible", "on");
            end
        end

        function onActionSelected(obj, ~, ~)
            switch obj.currentComparison
                case aod.schema.MatchType.SAME
                    return
                case aod.schema.MatchType.REMOVED
                case aod.schema.MatchType.CHANGED
                    disp('hey')
            end
        end

        function createUi(obj, parent)
            import aod.schema.MatchType

            if nargin < 2 || isempty(parent)
                parent = uifigure("Name", obj.testSpec.Name);
                parent.Position(3:4) = [50, -150] + parent.Position(3:4);
            end

            mainGrid = uigridlayout(parent, [3 1], "Padding", 0,...
                "RowHeight", {"1x", "fit", "fit"}, "BackgroundColor", 'w');

            gridLayout = uigridlayout(mainGrid, [2, 2],...
                "ColumnWidth", {'1x', '1x'}, "RowHeight", {"fit", "1x"},...
                "RowSpacing", 3, 'BackgroundColor', 'w');
            uilabel(gridLayout, "Text", "Current Specification",...
                "FontWeight", "bold", "FontSize", 14);
            uilabel(gridLayout, "Text", "Reference Specification",...
                "FontWeight", "bold", "FontSize", 14);
            obj.testListbox = uilistbox(gridLayout,...
                "Items", obj.getTestSpec(), "FontSize", 14);
            obj.testListbox.ValueChangedFcn = @obj.onValueSelected;
            obj.refListbox = uilistbox(gridLayout,...
                "Items", obj.getRefSpec(), "FontSize", 14);
            obj.refListbox.ValueChangedFcn = @obj.onValueSelected;

            actionLayout = uigridlayout(mainGrid, [1 3],...
                "ColumnWidth", {60, "1x", 60},...
                "BackgroundColor", [1 1 1]);
            obj.actionButton = uibutton(actionLayout,...
                "Icon", "", "Text", "", "Visible", "off",...
                "ButtonPushedFcn", @obj.onActionSelected);
            obj.actionButton.Layout.Column = 2;

            reportLayout = uigridlayout(mainGrid, [1 5],...
                "ColumnWidth", {"1x", "1x", "1x", "1x", "1x"},...
                "RowHeight", "fit", "RowSpacing", 5,...
                "Padding", 0, "ColumnSpacing", 0,...
                "BackgroundColor", [1 1 1]);
            labelParams = {"FontWeight", "bold", "FontSize", 14,...
                "HorizontalAlignment", "center"};
            obj.sameField =  uilabel(reportLayout,...
                "Text", sprintf("%u Same", nnz(obj.values == MatchType.SAME)),...
                "BackgroundColor", [0.95 0.95 0.95], labelParams{:});
            obj.stagedField = uilabel(reportLayout,...
                "BackgroundColor", [0.75 0.75 0.75],...
                "Text", "0 Staged", labelParams{:});
            obj.changedField = uilabel(reportLayout,...
                "BackgroundColor", obj.CHANGED.BackgroundColor,...
                "Text", "Changed", labelParams{:});
            obj.missingField = uilabel(reportLayout,...
                "BackgroundColor", obj.REMOVED.BackgroundColor,...
                labelParams{:});
            obj.unexpectedField = uilabel(reportLayout,...
                "BackgroundColor", obj.ADDED.BackgroundColor,...
                labelParams{:});

            idx = find(obj.values == MatchType.CHANGED);
            if ~isempty(idx)
                addStyle(obj.testListbox, obj.CHANGED, 'Item', idx);
                addStyle(obj.refListbox, obj.CHANGED, 'Item', idx);
            end
            obj.changedField.Text = sprintf("%u Changed", numel(idx));

            idx = find(obj.values == MatchType.REMOVED);
            if ~isempty(idx)
                addStyle(obj.testListbox, obj.REMOVED, 'Item', idx);
                addStyle(obj.refListbox, obj.REMOVED, 'Item', idx);
            end
            obj.missingField.Text = sprintf("%u Missing", numel(idx));

            idx = find(obj.values == MatchType.ADDED);
            if ~isempty(idx)
                addStyle(obj.testListbox, obj.ADDED, 'Item', idx);
                addStyle(obj.refListbox, obj.ADDED, 'Item', idx);
            end
            obj.unexpectedField.Text = sprintf("%u Unexpected", numel(idx));
        end

        function items = getRefSpec(obj)
            items = strings(numel(obj.keys), 1);
            for i = 1:numel(obj.keys)
                items(i) = obj.keys(i) + " - " + obj.refSpec.(obj.keys(i)).text();
            end
        end

        function items = getTestSpec(obj)
            items = strings(numel(obj.keys), 1);
            for i = 1:numel(obj.keys)
                items(i) = obj.keys(i) + " - " + obj.testSpec.(obj.keys(i)).text();
            end
        end
    end
end