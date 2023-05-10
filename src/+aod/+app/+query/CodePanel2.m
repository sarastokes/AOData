classdef CodePanel2 < aod.app.Component
% Interface for conversion of user input to MATLAB code
%
% Parent:
%   Component
%
% Constructor:
%   obj = aod.app.query.CodePanel(parent, canvas)
%
% Children:
%   N/A

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties
        codeEditor          weblab.components.CodeEditor
        copyButton          matlab.ui.control.Button 
        exportButton        matlab.ui.control.Button 
    end

    properties (SetAccess = private)
        isVisible 
    end

    methods 
        function obj = CodePanel2(parent, canvas)
            obj = obj@aod.app.Component(parent, canvas);
            obj.isVisible = false;
        end
    end

    methods
        function update(obj, varargin)
            if nargin > 1
                evt = varargin{1};
                if evt.EventType == "TabHidden"
                    obj.isVisible = false;
                elseif evt.EventType == "TabActive"
                    obj.isVisible = true;
                %elseif ismember(evt.EventType, ["AddExperiment", "AddNewFilter"])
                end
            end

            if obj.isVisible
                obj.createCode();
            end
        end
    end

    methods (Access = protected)
        function createUi(obj)
            mainLayout = uigridlayout(obj.Canvas, [2, 1],...
                "RowHeight", {"1x", 30}, "RowSpacing", 5);

            obj.codeEditor = weblab.components.CodeEditor();
            f = weblab.internal.Frame("Parent", mainLayout);
            f.insert(obj.codeEditor);
            obj.codeEditor.style('fontSize', '12px');

            buttonLayout = uigridlayout(mainLayout, [1 2],...
                "ColumnSpacing", 5, "Padding", [0 0 0 0]);
            obj.copyButton = uibutton(buttonLayout,...
                "Text", "Copy Code", "Icon", obj.getIcon("copy"));
            obj.exportButton = uibutton(buttonLayout,...
                "Text", "Export Code", "Icon", obj.getIcon("save"));

            obj.createCode();
        end
    end

    methods (Access = private)
        function createCode(obj)
            obj.codeEditor.Value = "% AOQuery: " + string(datetime("now")) + newline;
            obj.codeEditor.insertText(newline + "% Identify experiment files" + newline, "end");
            obj.codeExperiments();
            obj.codeEditor.insertText(newline + "% Create QueryManager" + newline, "end");
            obj.codeEditor.insertText("QM = aod.api.QueryManager(exptFiles);" + newline, "end");
            obj.codeEditor.insertText(newline + "% Add filters" + newline, "end");
            obj.codeFilters();
            obj.codeEditor.insertText(newline + "% Filter" + newline, "end");
            obj.codeEditor.insertText("[matches, entityInfo] = QM.filter();" + newline, "end");
        end

        function codeExperiments(obj)
            if isempty(obj.Root.Experiments)
                str = "exptFiles = [];" + newline;
                obj.codeEditor.insertText(str, "end");
                return
            end

            if obj.Root.numExperiments == 1
                str = "exptFiles = " + value2string(obj.Root.Experiments(1).hdfName) + ";" + newline;
                obj.codeEditor.insertText(str, "end");
                return
            end

            str = "exptFiles = [..." + newline;
            for i = 1:obj.Root.numExperiments
                str = str + "    " + value2string(obj.Root.Experiments(i).hdfName);
                if i < obj.Root.numExperiments
                    str = str + ";..." + newline;
                end
            end
            str = str + "];" + newline;
            obj.codeEditor.insertText(str, "end");
        end

        function codeFilters(obj)
            if isempty(obj.Root.Filters)
                return
            end
            for i = 1:numel(obj.Root.QueryManager.Filters)
                obj.codeEditor.insertText(...
                    sprintf("QM.addFilter(%s);",obj.Root.QueryManager.Filters(i).code()) + newline, "end");
                % TODO: Add filter inputs
                %obj.codeEditor.insertText("QM.addFilter();" + newline, "end");
            end
        end
    end
end