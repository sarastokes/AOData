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

            % Create the entity nodes
            for i = 1:height(entityTable)
                iNode = uitreenode(exptFolder,... 
                    "Text", h5tools.util.getPathEnd(entityTable.Path(i)),...
                    "Tag", entityTable.Path(i));
                addStyle(obj.Tree, obj.Icons(entityTable.Entity(i)), "Node", iNode);
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
            if obj.Root.numExperiments ~= 0
                for i = 1:obj.Root.numExperiments
                    obj.addExperiment(obj.Root.hdfFiles(i));
                end
            end
        end

        function onSelected_Node(obj, src, evt)
            if src.Tag == "Experiment"
                eventName = 'ExperimentSelected';
            else
                eventName = 'EntitySelected';
            end
            obj.publish(eventName, src);
        end
    end

    methods (Access = private)
        function loadIcons(obj)
            obj.Icons = containers.Map();

            iconPath = fullfile(aod.app.util.getIconFolder(), "+entity");
            iconPath = iconPath + filesep;

            obj.Icons('Experiment') = uistyle("FontWeight", "bold",...
                "Icon", iconPath + "experiment.png");
            obj.Icons('Source') = uistyle(...
                "Icon", iconPath + "contact-details.png");
            obj.Icons('System') = uistyle("FontWeight", "bold",...
                "Icon", iconPath + "telescope.png");
            obj.Icons('Channel') = uistyle(...
                "Icon", iconPath + "journey.png");
            obj.Icons('Device') = uistyle(...
                "Icon", iconPath + "led-diode.png");
            obj.Icons('Calibration') = uistyle(...
                "Icon", iconPath + "accuracy.png");
            obj.Icons('ExperimentDataset') = uistyle(...
                "Icon", iconPath + "grid.png");
            obj.Icons('Epoch') = uistyle("FontWeight", "bold",...
                "Icon", iconPath + "iris-scan.png");
            obj.Icons('Stimulus') = uistyle(...
                "Icon", iconPath + "spotlight.png");
            obj.Icons('Registration') = uistyle(...
                "Icon", iconPath + "motion-detector.png");
            obj.Icons('Response') = uistyle(...
                "Icon", iconPath + "electrical-threshold.png");
            obj.Icons('EpochDataset') = uistyle(...
                "Icon", iconPath + "hashtag-activity-grid.png");
            obj.Icons('Annotation') = uistyle(...
                "Icon", iconPath + "comments.png");
            obj.Icons('Analysis') = uistyle(...
                "Icon", iconPath + "graph.png");
        end
    end
end 