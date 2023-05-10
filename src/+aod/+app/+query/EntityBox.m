classdef EntityBox < aod.app.Component
% Interface for viewing entity-specific information
%
% Parent:
%   Component
%
% Constructor:
%   obj = aod.app.query.EntityBox(parent, canvas)
%
% Children:
%   N/A
%
% Events:
%   N/A

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties
        entityLayout        matlab.ui.container.GridLayout
        datasetText         matlab.ui.control.ListBox
        attrTable           matlab.ui.control.Table
        linkText            matlab.ui.control.ListBox
    end

    methods
        function obj = EntityBox(parent, canvas)
            obj = obj@aod.app.Component(parent, canvas);
        end
    end

    methods (Access = protected)
        function createUi(obj)
            obj.entityLayout = uigridlayout(obj.Canvas, [2, 1],...
                "RowHeight", {"fit", "fit"},...
                "RowSpacing", 3, "Padding", [0 0 0 0],...
                "Scrollable", "on");
            
            datasetLayout = uigridlayout(obj.entityLayout, [2 2],...
                "RowHeight", {obj.TEXT_HEIGHT, "1x"},...
                "Padding", [0 0 0 0], "RowSpacing", 1,...
                "ColumnSpacing", 3);
            datasetLayout.Layout.Row = 1;
            
            lbl1 = uilabel(datasetLayout, "Text", "Datasets:",...
                "FontWeight", "bold",...
                "HorizontalAlignment", "center",...
                "VerticalAlignment", "bottom");
            lbl1.Layout.Row = 1; lbl1.Layout.Column = 1;

            % Datasets
            obj.datasetText = uilistbox(datasetLayout,...
                "Items", {});
            obj.datasetText.Layout.Row = 2;
            obj.datasetText.Layout.Column = 1;

            % Links
            lbl2 = uilabel(datasetLayout, "Text", "Links:",...
                "FontWeight", "bold",...
                "HorizontalAlignment", "center",...
                "VerticalAlignment", "bottom");
            lbl2.Layout.Row = 1; lbl2.Layout.Column = 2;
            obj.linkText = uilistbox(datasetLayout,...
                "Items", {});
            obj.linkText.Layout.Row = 2;
            obj.linkText.Layout.Column = 2;
            
            % Attributes
            obj.attrTable = uitable(obj.entityLayout,...
                "ColumnName", {"Attribute", "Value"});
            obj.attrTable.Layout.Row = 2;
        end
    end
end 