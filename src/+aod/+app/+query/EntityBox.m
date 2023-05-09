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

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties
        entityLayout        matlab.ui.container.GridLayout
        datasetText         matlab.ui.control.TextArea
        attrTable           matlab.ui.control.Table
        linkText            matlab.ui.control.TextArea
    end

    methods
        function obj = EntityBox(parent, canvas)
            obj = obj@aod.app.Component(parent, canvas);
        end
    end

    methods
        function update(obj, varargin)
            obj.datasetText.Value = "Update registered!";
        end
    end

    methods (Access = protected)
        function createUi(obj)
            obj.entityLayout = uigridlayout(obj.Canvas, [6, 1],...
                "RowHeight", {"fit", "fit", "fit", "fit", "fit", "fit"},...
                "RowSpacing", 5, "Padding", [0 0 0 0],...
                "Scrollable", "on");
            
            uilabel(obj.entityLayout, "Text", "Datasets:",...
                "FontWeight", "bold",...
                "HorizontalAlignment", "center",...
                "VerticalAlignment", "bottom",...
                "BackgroundColor", rgb("peach"));
            obj.datasetText = uitextarea(obj.entityLayout,...
                "Value", "", "Editable", "off");
            uilabel(obj.entityLayout, "Text", "Links:",...
                "FontWeight", "bold",...
                "HorizontalAlignment", "center",...
                "VerticalAlignment", "bottom");
            obj.linkText = uitextarea(obj.entityLayout,...
                "Value", "", "Editable", "off");
            uilabel(obj.entityLayout, "Text", "Attributes:",...
                "FontWeight", "bold",...
                "VerticalAlignment", "bottom",...
                "HorizontalAlignment", "center");
            obj.attrTable = uitable(obj.entityLayout);
        end
    end
end 