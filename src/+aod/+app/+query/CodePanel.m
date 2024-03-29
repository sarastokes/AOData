classdef CodePanel < aod.app.Component
% Interface for conversion of user input to MATLAB code
%
% Parent:
%   aod.app.Component
%
% Constructor:
%   obj = aod.app.query.CodePanel(parent, canvas)
%
% Children:
%   N/A
%
% Events:
%   N/A

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties
        % Displays code generated by user input
        codeEditor      weblab.components.CodeEditor
        % Copies contents of codeEditor to clipboard
        copyButton      matlab.ui.control.Button
        % Exports contents of codeEditor as a MATLAB file
        exportButton    matlab.ui.control.Button 
        % Allows user to switch output from script to function
        outputDropdown      
    end

    properties (SetAccess = private)
        % Tracks whether component currently visible to user
        isVisible       logical
        % Tracks whether component ignored update events while hidden
        isDirty         logical
        % Whether output is script or function
        outputType      string  {mustBeMember(outputType, ["script", "function"])} = "script"
    end

    properties (Hidden, Constant)
        % These events always trigger a full component update
        UPDATE_EVENTS = ["AddExperiment", "RemoveExperiment",...
            "PushFilter", "PullFilter", "ClearFilters"];
    end

    methods 
        function obj = CodePanel(parent, canvas)
            obj = obj@aod.app.Component(parent, canvas);
            
            obj.isVisible = false;
            obj.isDirty = true;
        end
    end

    methods
        function update(obj, evt)
            if evt.EventType == "TabHidden"
                obj.isVisible = false;
            elseif evt.EventType == "TabActive"
                obj.isVisible = true;
                % Update if events were ignored while inactive
                if obj.isDirty
                    obj.createCode();
                end
            end

            if ismember(evt.EventType, obj.UPDATE_EVENTS)
                if obj.isVisible
                    obj.createCode();
                else 
                    % Mark as un-updated while hidden
                    obj.isDirty = true;
                end
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
            obj.codeEditor.Editable = false;

            buttonLayout = uigridlayout(mainLayout, [1 3],...
                "ColumnSpacing", 5, "Padding", [0 0 0 0]);
            obj.outputDropdown = uidropdown(buttonLayout,...
                "Items", ["script", "function"],...
                "ValueChangedFcn", @obj.onChanged_OutputType);
            obj.copyButton = uibutton(buttonLayout,...
                "Text", "Copy Code", "Icon", obj.getIcon("copy"),...
                "ButtonPushedFcn", @obj.onPush_CopyCode);
            obj.exportButton = uibutton(buttonLayout,...
                "Text", "Export Code", "Icon", obj.getIcon("save"),...
                "ButtonPushedFcn", @obj.onPush_ExportCode);

            obj.createCode();
        end

        function onChanged_OutputType(obj, ~, evt)
            if strcmp(evt.Value, evt.PreviousValue)
                return
            end
            obj.outputType = evt.Value;
            obj.createCode();
        end

        function onPush_CopyCode(obj, ~, ~)
            clipboard('copy', obj.codeEditor.Value);
        end

        function onPush_ExportCode(obj, ~, ~)
            textToNewFile(obj.codeEditor.Value);
        end
    end

    methods (Access = private)
        function createCode(obj)
            obj.codeEditor.Value = "";
            if obj.outputType == "script"
                value = "% AOQuery: " + string(datetime("now")) + newline;
                value = value + newline + "% Identify experiment files" + newline;
                value = obj.codeExperiments(value);
                ind = "";
            else
                value = "function [matches, entityInfo] = myQueryFcn(exptFiles)" + newline;
                ind = "    ";
            end
            value = value + newline + ind + "% Create QueryManager" + newline;
            value = value + ind + "QM = aod.api.QueryManager(exptFiles);" + newline;
            value = value + newline + ind + "% Add filters" + newline;
            value = obj.codeFilters(value, ind);
            value = value + newline + ind + "% Filter" + newline;
            value = value + ind + "[matches, entityInfo] = QM.filter();" + newline;
            if obj.outputType == "function"
                value = value + "end";
            end
            obj.codeEditor.Value = value;

            % Mark the component as up to date
            obj.isDirty = false;
        end

        function value = codeExperiments(obj, value)
            if obj.Root.numExperiments == 0
                str = "exptFiles = [];" + newline;
                value = value + str;
                return
            end

            if obj.Root.numExperiments == 1
                str = "exptFiles = " + value2string(obj.Root.hdfFiles) + ";" + newline;
                value = value + str;
                return
            end

            str = "exptFiles = [..." + newline;
            for i = 1:obj.Root.numExperiments
                str = str + "    " + value2string(obj.Root.hdfFiles(i));
                if i < obj.Root.numExperiments
                    str = str + ";..." + newline;
                end
            end
            str = str + "];" + newline;
            value = value + str;
        end

        function value = codeFilters(obj, value, ind)
            if isempty(obj.Root.numFilters)
                return
            end
            for i = 1:obj.Root.numFilters
                value = value + ind + ...
                    sprintf("QM.addFilter(%s);",obj.Root.QueryManager.Filters(i).code()) + newline;
            end
        end
    end
end