classdef SubfilterBox < aod.app.Component
% Interface for specifying subfilter inputs
%
% Parent:
%   aod.app.Component
%
% Constructor:
%   obj = aod.app.query.SubfilterBox(parent, canvas, ID)
%
% Children:
%   InputBox, FilterControls
%
% Events:
%   N/A

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        subID 
    end

    properties (Dependent)
        ID 
    end

    properties 
        gridLayout          matlab.ui.container.GridLayout 
        
        inputBox 
        filterControls
    end

    methods
        function obj = SubfilterBox(parent, canvas, ID)
            obj = obj@aod.app.Component(parent, canvas);
            obj.setHandler(aod.app.query.handlers.SubfilterBox(obj));
            obj.subID = ID;
            obj.gridLayout.Layout.Row = obj.subID + 1;
        end

        function value = get.ID(obj)
            value = obj.Parent.ID;
        end
    end

    methods
        function setSubfilterID(obj, newID)
            obj.subID = newID;
        end
    end

    methods
        function update(obj, evt)
            switch evt.EventType
                case "PushFilter"
                    obj.inputBox.Enable = "off";
                case "PullFilter"
                    obj.inputBox.Enable = "on";
            end
            obj.updateChildren(evt);
        end
    end

    methods (Access = protected)
        function value = specifyChildren(obj)
            value = [obj.inputBox; obj.filterControls];
        end
        
        function createUi(obj)
            obj.gridLayout = uigridlayout(obj.Canvas, [1 2],...
                "ColumnWidth", {"1x", 70},...
                "Padding", [0 0 0 0],...
                "RowHeight", obj.FILTER_HEIGHT);
            obj.gridLayout.Layout.Column = 1;

            obj.inputBox = aod.app.query.InputBox(obj, obj.gridLayout, true);
            obj.filterControls = aod.app.query.FilterControls(obj, obj.gridLayout, true);
        end
    end
end 