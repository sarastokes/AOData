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
%
% Events:
%   AddExperiment, RemoveExperiment

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties
        exptListbox         matlab.ui.control.ListBox 
        addButton           matlab.ui.control.Button 
        removeButton        matlab.ui.control.Button 
    end

    methods
        function obj = ExperimentPanel(parent, canvas)
            obj = obj@aod.app.Component(parent, canvas);

            obj.setHandler(aod.app.EventHandler(obj));
        end
    end

    methods
        function update(obj, evt)
            switch evt.EventType
                case "AddExperiment"
                    obj.exptListbox.Items = obj.Root.hdfFiles;
                    obj.removeButton.Enable = "on";
                case "RemoveExperiment"
                    obj.exptListbox.Items = obj.Root.hdfFiles;
                    if obj.Root.numExperiments == 0
                        obj.removeButton.Enable = "off";
                    end
            end
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
            if obj.Root.numExperiments ~= 0
                obj.exptListbox.Items = obj.Root.hdfFiles;
            end

            buttonLayout = uigridlayout(layout, [1 2],...
                "ColumnSpacing", 5, "Padding", [0 0 0 0]);
            obj.addButton = uibutton(buttonLayout,...
                "Text", "Add Experiment", ...
                "Icon", obj.getIcon("add"),...
                "ButtonPushedFcn", @obj.onPush_AddButton);
            obj.removeButton = uibutton(buttonLayout,...
                "Text", "Remove Experiment",... 
                "Icon", obj.getIcon("remove"),...
                "Enable", "off",...
                "ButtonPushedFcn", @obj.onPush_RemoveButton);
        end

        function onPush_AddButton(obj, ~, ~)
            if ispref('AOData', 'TestMode') && getpref('AOData', 'TestMode')
                fName = "ToyExperiment.h5";
                pathName = fullfile(getpref('AOData', 'BasePackage'), 'test');
                filterIdx = 1;
            else
                [fName, pathName, filterIdx] = uigetfile("*.h5",...
                    "Choose an AOData HDF5 file", "MultiSelect", "on");
            end
            if filterIdx == 0
                return
            end

            % Collect information about the new experiment
            exptFile = string(fullfile(pathName, fName));
            numExpts = numel(obj.exptListbox.Items);
            if numel(exptFile) > 1
                index = numExpts-numel(exptFile)+1:numExpts+numel(exptFile);
            else
                index = numel(exptFile);
            end

            obj.publish("AddExperiment", obj.exptListbox,...
                "FileName", exptFile, "Index", index);
        end

        function onPush_RemoveButton(obj, ~, ~)
            value = obj.exptListbox.Value;
            if isempty(value)
                error('onPush_RemoveButton:NoExperimentSelected',...
                    'Select an experiment to remove');
            end
            numExpts = numel(obj.exptListbox.Items);

            if numel(value) > 1
                index = [numExpts-numel(value)+1, numExpts];
            else
                index = numExpts;
            end

            obj.publish("RemoveExperiment", obj.exptListbox,... 
                "FileName", value, "ExperimentIndex", index);
        end
    end
end