classdef ExperimentPresenter < appbox.Presenter 
% Presenter for AODataViewer
%
% Parent:
%   appbox.Presenter
%
% Syntax:
%   obj = aod.app.presenters.ExperimentPresenter()
%
% See Also:
%   aod.app.views.ExperimentView, AODataViewer

% By Sara Patterson, 2022 (AOData)
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

            if nargin < 1 || isempty(experiment)
                experiment = obj.view.showGetFile('Chose an AOData H5 file', '*.h5');
                if isempty(experiment)
                    warning("ExperimentPresenter:NoExperiment",...
                        "No experiment provided, cancelling app");
                    obj.view.close();
                    return
                end
            end

            if isSubclass(experiment, 'aod.persistent.Experiment')
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
            % PARSEGROUP
            %
            % Description:
            %   Create group node and recursively call for all subgroups
            % -------------------------------------------------------------
            nodeParams = obj.attributes2map(group.Attributes);
            if nodeParams.isKey('Class') && strcmpi(nodeParams('Class'), 'container')
                nodeType = aod.app.AONodeTypes.CONTAINER;
            else
                nodeType = aod.app.AONodeTypes.ENTITY;
            end
            S = struct('Attributes', nodeParams, 'AONode', nodeType, ...
                'H5Node', aod.app.H5NodeTypes.GROUP,...
                'LoadState', aod.app.GroupLoadState.ATTRIBUTES);
            g = obj.view.makeEntityNode(parentNode, ...
                obj.getGroupName(group.Name), group.Name, S);
            if nodeType == aod.app.AONodeTypes.CONTAINER
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
            % 
            % Description:
            %   Create nodes for all datasets within an entity
            % -------------------------------------------------------------
            if isempty(entity.dsetNames) && isempty(entity.files)
                return
            end
            dsetNames = entity.dsetNames;
            for i = 1:numel(dsetNames)
                dsetPath = h5tools.util.buildPath(parentNode.Tag, dsetNames(i));
                info = h5info(obj.Experiment.hdfName, dsetPath);
                nodeData = struct(...
                    'H5Node', aod.app.H5NodeTypes.DATASET,...
                    'EntityPath', parentNode.Tag,...
                    'AONode', aod.app.AONodeTypes.get(entity.(dsetNames(i)), dsetNames(i)),...
                    'Attributes', obj.attributes2map(info.Attributes));
                g = obj.view.makeDatasetNode(parentNode, dsetNames(i),...
                    dsetPath, nodeData);
            end
        end

        function processEntityLinks(obj, parentNode, entity)
            % PROCESSENTITYLINKS
            %
            % Description:
            %   Create nodes for all links within an entity
            % -------------------------------------------------------------
            if isempty(entity.linkNames)
                return
            end
            for i = 1:numel(entity.linkNames)
                linkedEntity = entity.(entity.linkNames(i));

                obj.view.makeLinkNode(parentNode, entity.linkNames(i),...
                    h5tools.util.buildPath(parentNode.Tag, entity.linkNames(i)),...
                    linkedEntity.hdfPath);
            end
        end
    end

    % Callbacks
    methods (Access = private)
        function onViewSelectedNode(obj, ~, ~)
            obj.view.resetDisplay();
            node = obj.view.getSelectedNode();

            if isfield(node.NodeData, 'Attributes') && ~isempty(node.NodeData.Attributes)
                k = node.NodeData.Attributes.keys;
                v = node.NodeData.Attributes.values;
                data = table(k', v');
                obj.view.setAttributeTable(data);
            else
                obj.view.setAttributeTable();
            end

            if node.NodeData.H5Node == aod.app.H5NodeTypes.LINK
                obj.view.setLinkPanelView(node.NodeData.LinkPath);
            elseif node.NodeData.H5Node == aod.app.H5NodeTypes.DATASET
                displayType = node.NodeData.AONode.getDisplayType();
                if isempty(displayType)
                    return
                end
                entity = obj.Experiment.getByPath(node.Parent.Tag);
                data = entity.(node.Text);
                [displayType, data] = node.NodeData.AONode.displayInfo(data);
                obj.view.setDataDisplayPanel(displayType, data);
            end
        end

        function onViewExpandedNode(obj, ~, evt)
            % ONVIEWEXPANDEDNODE
            %
            % Description:
            %   When node is expanded, make sure everything is loaded in
            % -------------------------------------------------------------
            if isa(evt, 'matlab.ui.container.TreeNode')
                node = evt;
            else
                node = evt.data.Node;
            end

            % Only entity nodes require further loading
            if node.NodeData.AONode ~= aod.app.AONodeTypes.ENTITY
                return
            end

            % Check to see whether the entity node is already loaded
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

            % Load links and datasets
            entity = obj.Experiment.getByPath(node.Tag);
            obj.processEntityDatasets(node, entity);
            obj.processEntityLinks(node, entity);
            node.NodeData.LoadState = aod.app.GroupLoadState.CONTENTS;
        end

        function onViewFollowedLink(obj, ~, ~)
            node = obj.view.getSelectedNode;
            newNode = obj.view.path2node(node.NodeData.LinkPath);

            if ~isempty(newNode)
                obj.view.showNode(newNode);
                obj.view.selectNode(newNode);
                % Ensure Parent nodes get expanded properly
                iNode = newNode;
                while ~isa(iNode, 'matlab.ui.container.Tree')
                    obj.onViewExpandedNode([], iNode);
                    iNode = iNode.Parent;
                end
            end

        end

        function onViewCopyHdfAddress(obj, ~, ~)
            node = obj.view.getSelectedNode();
            hdfPath = node.Tag;
            if node.NodeData.H5Node ~= aod.app.H5NodeTypes.GROUP
                hdfPath = h5tools.util.buildPath(hdfPath, node.Text);
            end
            clipboard('copy', hdfPath);
        end

        function onViewSendNodeToBase(obj, ~, ~)
            node = obj.view.getSelectedNode();
            hdfPath = node.NodeData.hdfPath;
            e = obj.Experiment.getByPath(hdfPath);
            assignin('base', node.Text, e);
        end
        
        function onViewKeyPress(obj, ~, evt)
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