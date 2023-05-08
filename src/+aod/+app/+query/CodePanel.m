classdef CodePanel < aod.app.Component 
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

    events 
        CopyCode
        ExportCode
    end

    properties 
        codeBox             matlab.ui.control.TextArea
        copyButton          matlab.ui.control.Button 
        exportButton        matlab.ui.control.Button 
    end

    methods
        function obj = CodePanel(parent, canvas)
            obj = obj@aod.app.Component(parent, canvas);
        end
        
    end

    methods
        function update(obj, varargin)
            obj.createCode();
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
                "Text", "Copy Code", "Icon", []);
            obj.exportButton = uibutton(buttonLayout,...
                "Text", "Export Code", "Icon", []);

            obj.createCode();
        end
    end

    methods (Access = private)
        function createCode(obj)
            txt = "%% AOQuery: " + string(datetime("now")) + newline;
            txt = txt + newline;
            txt = txt + "%% Identify experiment files" + newline;
            txt = obj.codeExperiments(txt);
            txt = txt + "%% Create Query Manager" + newline;
            txt = obj.codeQueryManager(txt);
            txt = txt + "%% Add filters" + newline;
            txt = obj.codeFilters(txt);
            txt = txt + "%% Filter" + newline;
            txt = obj.codeFiltering(txt);
            obj.codeBox.Value = txt;
        end

        function txt = codeExperiments(obj, txt)
            str = "exptFiles = [..." + newline;
            for i = 1:obj.Root.numExperiments
                str = str + "    " + value2string(obj.Root.Experiments(i).hdfName);
                if i < obj.Root.numExperiments
                    str = str + ";..." + newline;
                end
            end 
            txt = txt + str + "];" + newline + newline;
        end

        function txt = codeQueryManager(obj, txt)
            txt = txt + "QM = aod.api.QueryManager(exptFiles);";
            txt = txt + newline + newline;
        end

        function txt = codeFilters(obj, txt)
            txt = txt + newline;
        end

        function txt = codeFiltering(obj, txt)
            txt = txt + "[matches, entityInfo] = QM.filter();" + newline;
        end
    end
end 