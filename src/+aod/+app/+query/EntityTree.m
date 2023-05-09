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
        Icons
    end

    methods
        function obj = EntityTree(parent, canvas)
            obj = obj@aod.app.Component(parent, canvas);

            obj.loadIcons();
        end

        function update(obj, varargin)

            if nargin == 2
                evt = varargin{1};
            end

            switch evt.EventType
                case "AddExperiment"
                    expt = obj.Root.Experiments(evt.Data.Index);
                    for i = 1:numel(expt)
                        obj.addExperiment(expt.Name, expt.hdfName);
                    end 
                case "RemoveExperiment"
                    if isempty(obj.Root.Experiments)
                        obj.reset();
                    else
                        % TODO: Remove specific experiments
                    end
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
        function addExperiment(obj, exptName, exptFile)
            arguments
                obj 
                exptName        string 
                exptFile        string 
            end

            tic
            [~, fName, ~] = fileparts(exptFile);
            exptFolder = uitreenode(obj.Tree, "Text", [char(fName), '.h5'],...
                "Tag", exptFile);
            uitreenode(exptFolder, "Text", exptName,...
                "Icon", obj.Icons('Experiment'),...
                "Tag", "/Experiment");
            entityTable = obj.Root.QueryManager.entityTable;
            entityTable = entityTable(entityTable.File == exptFile, :);
            for i = 1:height(entityTable)
                uitreenode(exptFolder,... 
                    "Text", h5tools.util.getPathEnd(entityTable.Path(i)),...
                    "Icon", obj.Icons(entityTable.Entity(i)),...
                    "Tag", entityTable.Path(i));
            end
            fprintf('Time = %.2f\n', toc);
        end

        function removeExperiment(obj, exptPath)
            h = findobj(obj.Tree, "Tag", exptPath);
            delete(h);
        end
    end

    methods (Access = protected)
        function createUi(obj)
            obj.Tree = uitree(aod.app.util.uilayoutfill(obj.Canvas),...
                "SelectionChangedFcn", @obj.onSelected_Node);
            if ~isempty(obj.Root.Experiments)
                %! Add experiments
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
            obj.Icons('System') = fullfile(iconPath, "test-bench.png");
            obj.Icons('Channel') = fullfile(iconPath, "microscope.png");
            obj.Icons('Device') = fullfile(iconPath, "engineering.png");
            obj.Icons('Calibration') = fullfile(iconPath, "energy-meter.png");
            obj.Icons('ExperimentDataset') = fullfile(iconPath, "grid.png");
            obj.Icons('Epoch') = fullfile(iconPath, "movie.png");
            obj.Icons('Stimulus') = fullfile(iconPath, "spotlight.png");
            obj.Icons('Registration') = fullfile(iconPath, "motion-detector.png");
            obj.Icons('Response') = fullfile(iconPath, "ecg.png");
            obj.Icons('EpochDataset') = fullfile(iconPath, "hashtag-activity-grid.png");
            obj.Icons('Annotation') = fullfile(iconPath, "comments.png");
            obj.Icons('Analysis') = fullfile(iconPath, "accounting.png");

        end
    end
end 