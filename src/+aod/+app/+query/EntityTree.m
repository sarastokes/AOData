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
    end

    methods
        function obj = EntityTree(parent, canvas)
            obj = obj@aod.app.Component(parent, canvas);
        end

        function update(obj, varargin)

            if nargin == 2
                evt = varargin{1};
            end

            switch evt.EventType
                case "AddExperiment"
                    expt = obj.Root.Experiments(evt.Data.Index);
                    for i = 1:numel(expt)
                        obj.addExperiment(expt.Name, expt.hdfPath);
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
        function addExperiment(obj, exptName, exptPath)
            %if ~isscalar(exptName)
            %    arrayfun(@(x) addExperiment(obj, x), exptName);
            %    return
            %end

            uitreenode(obj.Tree, "Text", exptName,...
                "Icon", obj.getIcon("folder"),...
                "Tag", exptPath);
        end

        function removeExperiment(obj, exptPath)
            %if ~isscalar(exptName)
            %    arrayfun(@(x) removeExperiment(obj, x), exptPath);
            %    return
            %end
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
end 