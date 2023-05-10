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
        codeBox             matlab.ui.control.TextArea
        copyButton          matlab.ui.control.Button 
        exportButton        matlab.ui.control.Button 
    end

    properties (SetAccess = private)
        isVisible           logical
    end

    methods
        function obj = CodePanel(parent, canvas)
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
            obj.codeBox = uitextarea(mainLayout,...
                "FontName", "consolas",...
                "HorizontalAlignment", "left",...
                "Value", "", "Editable", "off");
            buttonLayout = uigridlayout(mainLayout, [1 2],...
                "ColumnSpacing", 5, "Padding", [0 0 0 0]);
            obj.copyButton = uibutton(buttonLayout,...
                "Text", "Copy Code", "Icon", [],...
                "ButtonPushedFcn", @obj.onPush_CopyCode);
            obj.exportButton = uibutton(buttonLayout,...
                "Text", "Export Code", "Icon", [],...
                "ButtonPushedFcn", @obj.onPush_ExportCode);

            obj.createCode();
        end

        function onPush_CopyCode(obj, ~, ~)
            clipboard('copy', obj.codeBox.Value);
        end

        function onPush_ExportCode(~, ~, ~)
            % TODO: Export code interface
        end
    end

    methods (Access = private)
        function createCode(obj)
            txt = "%% AOQuery: " + string(datetime("now")) + newline;
            txt = txt + newline;
            
            txt = txt + "%% Identify experiment files" + newline;
            txt = obj.codeExperiments(txt);

            txt = txt + "%% Create Query Manager" + newline;
            txt = txt + "QM = aod.api.QueryManager(exptFiles);";
            txt = txt + newline + newline;

            txt = txt + "%% Add filters" + newline;
            txt = obj.codeFilters(txt);

            txt = txt + "%% Filter" + newline;
            txt = txt + "[matches, entityInfo] = QM.filter();" + newline;
            obj.codeBox.Value = txt;
        end

        function txt = codeExperiments(obj, txt)
            str = "exptFiles = [..." + newline;
            for i = 1:obj.Root.numExperiments
                str = str + "    " + value2string(obj.Root.hdfFiles(i));
                if i < obj.Root.numExperiments
                    str = str + ";..." + newline;
                end
            end 
            txt = txt + str + "];" + newline + newline;
        end

        function txt = codeFilters(obj, txt)
            txt = txt + newline;
        end
    end
end 