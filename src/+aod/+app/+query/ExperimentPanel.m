classdef ExperimentPanel < aod.app.Component 
% Panel for adding and removing experiments from query
%
% Superclass:
%   aod.app.Component
%
% Syntax:
%   obj = aod.app.query.ExperimentPanel(parent, canvas)
%
% Children:
%   N/A

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    events
        AddExperiment
        RemoveExperiment
    end

    properties
        exptListbox         matlab.ui.control.ListBox 
        addButton           matlab.ui.control.Button 
        removeButton        matlab.ui.control.Button 
    end

    methods
        function obj = ExperimentPanel(parent, canvas)
            obj = obj@aod.app.Component(parent, canvas);

            obj.setHandler(aod.app.query.ExperimentPanelHandler(obj));
        end
    end

    methods (Access = protected)
        function createUi(obj)
            layout = uigridlayout(obj.Canvas, [2 1],...
                "RowHeight", {30, "1x", 30}, "RowSpacing", 5);
            uilabel(layout, "Text", "Experiments:",...
                "FontWeight", "bold", "FontSize", 12,...
                "HorizontalAlignment", "center");
            obj.exptListbox = uilistbox(layout,...
                "Items", {});
            buttonLayout = uigridlayout(layout, [1 2],...
                "ColumnSpacing", 5, "Padding", [0 0 0 0]);
            obj.addButton = uibutton(buttonLayout,...
                "Text", "Add Experiment", ...
                "Icon", obj.getIcon("add"),...
                "ButtonPushedFcn", @obj.onPush_AddButton);
            obj.removeButton = uibutton(buttonLayout,...
                "Text", "Remove Experiment",... 
                "Icon", obj.getIcon("remove"),...
                "Enable", "off");
        end

        function onPush_AddButton(obj, ~, ~)
            [fName, pathName, filterIdx] = uigetfile("*.h5",...
                "Choose an AOData HDF5 file", "MultiSelect", "on");
            if filterIdx == 0
                return
            end
            exptFile = string(fullfile(pathName, fName));
            evtData = aod.app.Event("AddExperiment",... 
                obj.exptListbox, 'FileName', exptFile);
            notify(obj, 'NewEvent', evtData);
        end

        function onPush_RemoveButton(obj, ~, ~)
            value = obj.exptListbox.Value;
            disp(value);
            evtData = aod.app.Event("RemoveExperiment",... 
                obj.exptListbox, 'FileName', value);
        end
    end
end