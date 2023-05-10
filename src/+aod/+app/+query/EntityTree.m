classdef EntityTree < aod.app.Component 
% Tree displaying experiments and matched entities
%
% Superclass:
%   aod.app.Component
%
% Constructor:
%   obj = aod.app.query.EntityTree(parent, canvas)
%
% Children:
%   N/A

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    events
        SelectedNode
    end

    properties
        Tree            matlab.ui.container.Tree
        UnmatchedNode   matlab.ui.container.TreeNode
        Icons
    end

    properties (SetAccess = private)
        % Whether entity tree currently has the focus
        isActive        logical = true
        % Whether tree needs an update when next focused
        isDirty         logical = false
    end

    properties (Hidden, Constant)
        BOLD_STYLE = uistyle("FontWeight", "bold");
    end

    methods
        function obj = EntityTree(parent, canvas)
            obj = obj@aod.app.Component(parent, canvas);

            obj.loadIcons();
        end
    end

    methods 
        function update(obj, varargin)

            if nargin < 2
                return
            end

            evt = varargin{1};

            switch evt.EventType
                case "AddExperiment"
                    for i = 1:numel(evt.Data.FileName)
                        obj.addExperiment(evt.Data.FileName(i));
                    end 
                case "RemoveExperiment"
                    obj.removeExperiment(evt.Data.FileName);
                case "Filter"
            end
        end

        function reset(obj)
            if isempty(obj.Root.Experiments)
                delete(obj.Tree.Children)
            else
                h = findall(obj.Tree, "Tag", "Experiment");
                for i = 1:numel(h)
                    delete(h(i).Children);
                end
            end
            %! Populate matches
        end
    end

    methods 
        function addExperiment(obj, exptFile)
            arguments
                obj 
                exptFile        string 
            end

            tic
            % Create the experiment node
            [~, fName, ~] = fileparts(exptFile);
            exptFolder = uitreenode(obj.Tree,... 
                "Text", [char(fName), '.h5'],...
                "Tag", exptFile);
            uitreenode(obj.UnmatchedNode,...
                "Text", [char(fName), '.h5'],...
                "Tag", exptFile);
            % Collect the entity information
            entityTable = obj.Root.QueryManager.entityTable;
            entityTable = entityTable(entityTable.File == exptFile, :);
            entityTable = sortrows(entityTable, "Path", "ascend");

            % Identifiy top-level nodes
            isBold = ismember(entityTable.Entity, ["Epoch", "Experiment"]);
            % Create the entity nodes
            for i = 1:height(entityTable)
                iNode = uitreenode(exptFolder,... 
                    "Text", h5tools.util.getPathEnd(entityTable.Path(i)),...
                    "Icon", obj.Icons(entityTable.Entity(i)),...
                    "Tag", entityTable.Path(i));
                % Emphasize experiment and epoch
                if isBold(i)
                    addStyle(obj.Tree, obj.BOLD_STYLE, "node", iNode);
                end
            end
            fprintf('Entity Tree Time = %.2f\n', toc);
        end

        function removeExperiment(obj, exptFile)
            % Delete the experiment from the main tree and unmatched
            h = findobj(obj.Tree, "Tag", exptFile);
            delete(h);
        end
    end

    methods (Access = protected)
        function createUi(obj)
            obj.Tree = uitree(aod.app.util.uilayoutfill(obj.Canvas),...
                "SelectionChangedFcn", @obj.onSelected_Node);
            obj.UnmatchedNode = uitreenode(obj.Tree,...
                "Text", "Unmatched entities");
            if ~isempty(obj.Root.Experiments)
                %! Add experiments, if present
            end
        end

        function onSelected_Node(obj, src, evt)
            if src.Tag == "Experiment"
                eventName = 'ExperimentSelected';
            else
                eventName = 'EntitySelected';
            end
            evtData = aod.app.Event(eventName, src);
            notify(obj, 'NewEvent', evtData);
        end
    end

    methods (Access = private)
        function loadIcons(obj)
            obj.Icons = containers.Map();

            iconPath = fullfile(aod.app.util.getIconFolder(), "+entity");

            obj.Icons('Experiment') = fullfile(iconPath, "experiment.png");
            obj.Icons('Source') = fullfile(iconPath, "contact-details.png");
            obj.Icons('System') = fullfile(iconPath, "telescope.png");
            obj.Icons('Channel') = fullfile(iconPath, "journey.png");
            obj.Icons('Device') = fullfile(iconPath, "led-diode.png");
            obj.Icons('Calibration') = fullfile(iconPath, "accuracy.png");
            obj.Icons('ExperimentDataset') = fullfile(iconPath, "grid.png");
            obj.Icons('Epoch') = fullfile(iconPath, "iris-scan.png");
            obj.Icons('Stimulus') = fullfile(iconPath, "spotlight.png");
            obj.Icons('Registration') = fullfile(iconPath, "motion-detector.png");
            obj.Icons('Response') = fullfile(iconPath, "electrical-threshold.png");
            obj.Icons('EpochDataset') = fullfile(iconPath, "hashtag-activity-grid.png");
            obj.Icons('Annotation') = fullfile(iconPath, "comments.png");
            obj.Icons('Analysis') = fullfile(iconPath, "graph.png");

        end
    end
end 