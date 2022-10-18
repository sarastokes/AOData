classdef ExperimentPresenter < appbox.Presenter 
% EXPERIMENTVIEW
%
% Parent:
%   appbox.Presenter
%
% Syntax:
%   obj = ExperimentPresenter()
%
% See also:
%   aod.app.views.ExperimentView
% -------------------------------------------------------------------------

    properties 
        Experiment
    end

    properties (Hidden, Constant)
        DEBUG = true;
        SYSTEM_ATTRIBUTES = ["UUID", "description", "Class", "EntityType"];
        CONTAINER_STYLE = uistyle("FontAngle", "italic");
        ICON_DIR = [fileparts(fileparts(mfilename('fullpath'))),...
            filesep, '+icons', filesep];
    end
    
    methods
        function obj = ExperimentPresenter(experiment, view)
            if nargin < 2
                view = aod.app.views.ExperimentView();
            end
            obj = obj@appbox.Presenter(view);

            if isSubclass(experiment, 'aod.core.persistent.Experiment')
                obj.Experiment = experiment;
            else
                obj.Experiment = loadExperiment(experiment);
            end

            obj.go();
        end

        function v = getFigure(obj)
            % For development, remove later
            v = obj.view.getFigure();
        end

        function v = getView(obj)
            v = obj.view;
        end

        function e = node2entity(obj, node)
            e = obj.Experiment.getByPath(node.Tag);
        end
    end

    methods (Access = protected)
        function willGo(obj)
            % Set the title
            obj.view.setTitle(obj.Experiment.label);
            S = h5info(obj.Experiment.hdfName);
            if ~isempty(S.Groups)
                for i = 1:numel(S.Groups)
                    obj.parseGroup(S.Groups(i), obj.view.Tree);
                end
            end
        end

        function willStop(obj)
            obj.view.reportDeletedNode = false;
        end

        function oldCode(obj)
            % Populate just the group names
            groupNames = aod.h5.HDF5.collectGroups(obj.Experiment.hdfName);
            assignin('base', 'groupNames', groupNames);
            obj.view.populateEntityNode(groupNames(1), obj.view.Tree);
            for i = 2:numel(groupNames)
                if ismember(aod.h5.HDF5.getPathEnd(groupNames(i)),... 
                        aod.core.EntityTypes.allContainerNames())
                    obj.view.populateContainerNode(groupNames(i));
                else
                    obj.view.populateEntityNode(groupNames(i));
                end
            end
        end

        function bind(obj)
            bind@appbox.Presenter(obj);

            v = obj.view();
            obj.addListener(v, 'KeyPress', @obj.onViewKeyPress);
            obj.addListener(v, 'NodeSelected', @obj.onViewSelectedNode);
            obj.addListener(v, 'NodeExpanded', @obj.onViewExpandedNode);
            obj.addListener(v, 'NodeDoubleClicked', @obj.onViewDoubleClickedNode);
            obj.addListener(v, 'LinkFollowed', @obj.onViewFollowedLink);
            obj.addListener(v, 'SendNodeToBase', @obj.onViewSendNodeToBase);
            obj.addListener(v, 'CopyHdfAddress', @obj.onViewCopyHdfAddress);
        end
    end

    methods 
        function parseGroup(obj, group, parentNode)
            nodeParams = obj.attributes2map(group.Attributes);
            if nodeParams.isKey('Class') && strcmpi(nodeParams('Class'), 'container')
                nodeType = 'container';
            else
                nodeType = 'entity';
            end
            S = struct('Attributes', nodeParams, 'NodeType', nodeType, ...
                'LoadState', aod.app.GroupLoadState.ATTRIBUTES);
            g = obj.view.makeEntityNode(parentNode, ...
                obj.getGroupName(group.Name), group.Name, S);
            if strcmp(nodeType, 'container')
                obj.view.formatContainerNode(g);
            else
                obj.view.makePlaceholderNode(g);
            end

            S = h5info(obj.Experiment.hdfName, group.Name);

            if ~isempty(S.Groups)
                for i = 1:numel(S.Groups)
                    obj.parseGroup(S.Groups(i), g);
                end
            end
        end

        function processEntityDatasets(obj, parentNode, entity)
            % PROCESSENTITYDATASETS
            if isempty(entity.dsetNames) && isempty(entity.files)
                return
            end
            dsetNames = entity.dsetNames;
            if ~isempty(entity.files)
                dsetNames = cat(2, dsetNames, "files");
            end
            for i = 1:numel(dsetNames)
                info = h5info(obj.Experiment.hdfName,...
                    aod.h5.HDF5.buildPath(parentNode.Tag, dsetNames(i)));
                assignin('base', 'info', info);
                nodeData = struct(...
                    'H5Node', aod.app.H5NodeTypes.DATASET,...
                    'EntityPath', parentNode.Tag,...
                    'AONode', aod.app.AONodeTypes.get(class(entity.(dsetNames(i)))),...
                    'Attributes', obj.attributes2map(info.Attributes));
                if dsetNames(i) == "files"
                    nodeData.AONode = aod.app.AONodeTypes.FILES;
                end
                g = obj.view.makeDatasetNode(parentNode, dsetNames(i),...
                    parentNode.Tag, nodeData);
            end
        end

        function processEntityLinks(obj, parentNode, entity)
            % PROCESSENTITYLINKS
            if isempty(entity.linkNames)
                return
            end
            for i = 1:numel(entity.linkNames)
                linkedEntity = entity.(entity.linkNames(i));

                obj.view.makeLinkNode(parentNode, entity.linkNames(i),...
                    linkedEntity.hdfPath);
            end
        end
    end

    % Callbacks
    methods (Access = private)
        function onViewDoubleClickedNode(obj, src, evt)
            assignin('base', 'src', src);
            assignin('base', 'evt', evt);
            node = evt.InteractionInformation.Node;
            if ~isempty(node)
                open(obj.view.ContextMenu, src.CurrentPoint(1), src.CurrentPoint(2));
            end
        end

        function onViewSelectedNode(obj, ~, ~)
            obj.view.resetDisplay();
            node = obj.view.getSelectedNode();
            assignin('base', 'node', node);

            % if isfield(node.NodeData, 'Attributes') %&& ~node.NodeData.LoadState.hasAttributes()
            %    info = h5info(obj.Experiment.hdfName, node.Tag);
            %    nodeParams = obj.attributes2map(info.Attributes);
            %    node.NodeData.Attributes = nodeParams;
            %    node.NodeData.LoadState = aod.app.GroupLoadState.ATTRIBUTES;
            % end
            
            if isfield(node.NodeData, 'Attributes') && ~isempty(node.NodeData.Attributes)
                k = node.NodeData.Attributes.keys;
                v = node.NodeData.Attributes.values;
                data = table(k', v');
                obj.view.setAttributeTable(data);
            else
                obj.view.setAttributeTable();
            end
        end

        function onViewExpandedNode(obj, ~, evt)
            % ONVIEWEXPANDEDNODE
            %
            % Description:
            %   When node is expanded, make sure everything is loaded in
            % -------------------------------------------------------------
            assignin('base', 'evt', evt);
            node = evt.data.Node;

            switch lower(node.NodeData.NodeType)
                case 'entity'
                    if node.NodeData.LoadState == aod.app.GroupLoadState.CONTENTS
                        return
                    end
                    % Delete the placeholder node
                    idx = find(arrayfun(@(x) isequal(x.Text, 'Placeholder'),...
                        node.Children));
                    if ~isempty(idx)
                        delete(node.Children(idx));
                    end
                    obj.view.update();

                    entity = obj.Experiment.getByPath(node.Tag);
                    obj.processEntityDatasets(node, entity);
                    obj.processEntityLinks(node, entity);
                    node.NodeData.LoadState = aod.app.GroupLoadState.CONTENTS;
                case 'dataset'
                    % TODO: Dataset parsing
                case 'link'
                    e = obj.node2entity(node);
                    obj.view.setLinkPanelView(e.(node.Text));
            end
        end

        function onViewFollowedLink(obj, ~, ~)
            if obj.DEBUG
                return
            end
        end

        function onViewCopyHdfAddress(obj, ~, ~)
            node = obj.view.getSelectedNode();
            hdfPath = node.NodeData.hdfPath;
            clipboard('copy', hdfPath);
        end

        function onViewSendNodeToBase(obj, ~, ~)
            node = obj.view.getSelectedNode();
            hdfPath = node.NodeData.hdfPath;
            e = obj.Experiment.getByPath(hdfPath);
            assignin('base', node.Text, e);
        end
        
        function onViewKeyPress(obj, ~, evt)
            assignin('base', 'evt', evt);
            switch evt.data.Key
                case 'c'
                    node = obj.view.getSelectedNode();
                    if ~isempty(node)
                        node.collapse();
                    end
                case 'x'
                    node = obj.view.getSelectedNode();
                    node.collapse();
                    if ~isempty(node)
                        node.Parent.collapse();
                    end
            end
        end
    end

    methods (Static)
        function groupName = getGroupName(fullName)
            txt = strsplit(fullName, '/');
            groupName = txt{end};
        end

        function nodePath = getNodePath(node)
            nodePath = node.Text;
            nodeParent = node.Parent;
            while ~isa(nodeParent, 'matlab.ui.container.Tree')
                nodePath = [nodeParent.Text, '/', nodePath]; %#ok
                node = node.Parent;
                nodeParent = node.Parent;
            end
            nodePath = ['/', nodePath];
        end
        
        function S = attributes2map(attributes)
            S = containers.Map();
            for i = 1:numel(attributes)
                value = attributes(i).Value;
                if isnumeric(value)
                    value = num2str(value);
                elseif iscell(value) && numel(value) == 1
                    value = value{:};
                end
                S(attributes(i).Name) = value;
            end
        end
    end
end 