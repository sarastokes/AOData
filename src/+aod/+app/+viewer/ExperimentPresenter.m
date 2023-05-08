classdef ExperimentPresenter < appbox.Presenter 
% Presenter for AODataViewer
%
% Parent:
%   appbox.Presenter
%
% Syntax:
%   obj = aod.app.viewer.ExperimentPresenter(experiment)
%   obj = aod.app.viewer.ExperimentPresenter(experiment, view)
%
% Inputs:
%   experiment      char/string or aod.persistent.Experiment
%
% Optional inputs:
%   view            aod.app.UIView (default=aod.app.viewer.ExperimentView)
%       Use if you want to create a modified version of ExperimentView 
%
% See also:
%   aod.app.viewer.ExperimentView, AODataViewer

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties 
        Experiment              aod.persistent.Experiment 
        EntityTable
        hdfName
    end

    properties (Hidden, Constant)
        DEBUG = true;
        SYSTEM_ATTRIBUTES = ["UUID", "description", "Class", "EntityType", "label"];
        CONTAINER_STYLE = uistyle("FontAngle", "italic");
        ICON_DIR = [fileparts(fileparts(mfilename('fullpath'))),...
            filesep, '+icons', filesep];
    end
    
    methods
        function obj = ExperimentPresenter(experiment, view)
            %
            % Inputs:
            %   experiment      aod.persistent.Experiment
            %   
            % -------------------------------------------------------------
            if nargin < 2
                view = aod.app.viewer.ExperimentView();
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
            obj.hdfName = obj.Experiment.hdfName;

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
            % Extract entity from a node
            e = obj.Experiment.getByPath(node.Tag);
        end
    end

    methods (Access = protected)
        function willGo(obj)
            % Set the title
            obj.view.setTitle(obj.Experiment.label);
            T = obj.Experiment.factory.entityManager.table();

            % Sort entities by path length to ensure parents are created 
            % before their children in the hierarchy
            pathLength = h5tools.util.getPathOrder(T.Path);
            [~, idx] = sort(pathLength);
            obj.EntityTable = T(idx, :);
            % Create each entity's node (and containers)
            for i = 1:height(obj.EntityTable)
                obj.parseEntityGroup(...
                    obj.EntityTable.Path(i), obj.EntityTable.Entity(i));
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
        function parseEntityGroup(obj, path, entityType)
        
            parentPath = h5tools.util.getPathParent(path);
            attrs = h5tools.readatt(obj.hdfName, path, "all");

            % Create the node data
            S = struct(...
                'HdfFile', obj.hdfName,...
                'AONode', aod.app.util.AONodeTypes.ENTITY,...
                'H5Node', aod.app.util.H5NodeTypes.GROUP,...
                'LoadState', aod.app.util.GroupLoadState.ATTRIBUTES,...
                'Attributes', attrs);

            % Direct view to make the node
            g = obj.view.makeEntityNode(parentPath,... 
                h5tools.util.getPathEnd(path), path, S);

            % Create child containers, if necessary
            entityType = aod.core.EntityTypes.get(entityType);
            childTypes = entityType.childContainers();
            if ~isempty(childTypes)
                for i = 1:numel(childTypes)
                    containerPath = h5tools.util.buildPath(path, childTypes(i));
                    containerAttrs = obj.att2display(h5tools.readatt(...
                        obj.hdfName, containerPath, "all"));
                    S = struct(...
                        'HdfFile', obj.hdfName,...
                        'AONode', aod.app.util.AONodeTypes.CONTAINER,...
                        'H5Node', aod.app.util.H5NodeTypes.GROUP,...
                        'LoadState', aod.app.util.GroupLoadState.CONTENTS,...
                        'Attributes', containerAttrs);
                    g = obj.view.makeEntityNode(path,...
                        childTypes(i), containerPath, S);
                end
            end
        end 

        function processEntityDatasets(obj, parentNode, entity)
            % Create nodes for all datasets within an entity
            %
            % Notes:
            %   Relies on persistent interface to populate datasets
            % -------------------------------------------------------------

            % Look for datasets and files (which is a dataset)
            if isempty(entity.dsetNames) && isempty(entity.files)
                return
            end

            dsetNames = entity.dsetNames;
            for i = 1:numel(dsetNames)
                % Build the dataset's HDF5 path
                dsetPath = h5tools.util.buildPath(parentNode.Tag, dsetNames(i));

                % Get attributes with h5info
                attrs = obj.att2display(h5tools.readatt(...
                    obj.Experiment.hdfName, dsetPath, "all"));

                % Create the nodeData struct
                nodeData = struct(...
                    'HdfFile', obj.hdfName,...
                    'H5Node', aod.app.util.H5NodeTypes.DATASET,...
                    'AONode', aod.app.util.AONodeTypes.get(entity.(dsetNames(i)), dsetNames(i)),...
                    'LoadState', aod.app.util.GroupLoadState.ATTRIBUTES,...
                    'Attributes', attrs);

                % Make the node
                obj.view.makeDatasetNode(parentNode, dsetNames(i),...
                    dsetPath, nodeData);
            end
        end

        function processEntityLinks(obj, parentNode, entity)
            % Create nodes for all links within an entity
            % -------------------------------------------------------------
            if isempty(entity.linkNames)
                return
            end

            for i = 1:numel(entity.linkNames)
                % Get HDF5 path
                linkPath = h5tools.util.buildPath(parentNode.Tag, entity.linkNames(i));

                % Get the linked entity name
                linkedEntity = entity.(entity.linkNames(i));
                
                % Get the attributes
                attrs = obj.att2display(h5tools.readatt(...
                    obj.Experiment.hdfName, linkPath, "all"));
                
                % Create the nodeData struct
                nodeData = struct(...
                    'HdfFile', obj.hdfName,...
                    'LinkPath', linkedEntity.hdfPath,...
                    'H5Node', aod.app.util.H5NodeTypes.LINK,...
                    'AONode', aod.app.util.AONodeTypes.LINK,...
                    'Attributes', attrs);

                obj.view.makeLinkNode(parentNode,... 
                    entity.linkNames(i), linkPath, nodeData);
            end
        end
    end

    % Callbacks
    methods (Access = private)
        function onViewSelectedNode(obj, ~, ~)
            % Set up view based on contents of selected node
            obj.view.resetDisplay();
            node = obj.view.getSelectedNode();

            % Display node's attributes, importing if needed
            if ~isempty(node.NodeData.Attributes)
                k = node.NodeData.Attributes.keys;
                v = node.NodeData.Attributes.values;
                data = table(k', v');
                obj.view.setAttributeTable(data);
            else
                obj.view.setAttributeTable();
            end

            % Create data display
            if node.NodeData.H5Node == aod.app.util.H5NodeTypes.LINK
                obj.view.setLinkPanelView(node.NodeData.LinkPath);
            elseif node.NodeData.H5Node == aod.app.util.H5NodeTypes.DATASET
                displayType = node.NodeData.AONode.getDisplayType();
                if isempty(displayType)
                    return
                end
                % Get the data from the entity's properties
                entity = obj.Experiment.getByPath(node.Parent.Tag);
                data = entity.(node.Text);
                % Determine appropriate display and reformat data if needed
                [displayType, data] = node.NodeData.AONode.displayInfo(data);
                obj.view.setDataDisplayPanel(displayType, data);
            end
        end

        function onViewExpandedNode(obj, ~, evt)
            % When node is expanded, make sure contents are loaded
            %
            % Notes:
            %   evt can be event data or a TreeNode. The second option is 
            %   necessary so that link follows can correctly expand any 
            %   collapsed parent nodes. 
            % -------------------------------------------------------------
            if isa(evt, 'matlab.ui.container.TreeNode')
                node = evt;
            else
                node = evt.data.Node;
            end

            % Only entity nodes require further loading
            if node.NodeData.AONode ~= aod.app.util.AONodeTypes.ENTITY
                return
            end

            % Check to see whether the entity node is already loaded
            if node.NodeData.LoadState == aod.app.util.GroupLoadState.CONTENTS
                return
            end

            % Delete the placeholder node
            idx = find(arrayfun(@(x) isequal(x.Text, 'Loading...'),...
                node.Children));
            if ~isempty(idx)
                delete(node.Children(idx));
            end
            %obj.view.update();

            % Load links and datasets
            entity = obj.Experiment.getByPath(node.Tag);
            obj.processEntityDatasets(node, entity);
            obj.processEntityLinks(node, entity);

            % Mark node as fully loaded
            node.NodeData.LoadState = aod.app.util.GroupLoadState.CONTENTS;
        end

        function onViewFollowedLink(obj, ~, ~)
            node = obj.view.getSelectedNode;
            newNode = obj.view.path2node(node.NodeData.LinkPath);

            if ~isempty(newNode)
                obj.view.showNode(newNode);
                obj.view.selectNode(newNode);

                % Ensure Parent nodes are expanded properly
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
            if node.NodeData.H5Node ~= aod.app.util.H5NodeTypes.GROUP
                hdfPath = h5tools.util.buildPath(hdfPath, node.Text);
            end
            clipboard('copy', hdfPath);
        end

        function onViewSendNodeToBase(obj, ~, ~)
            node = obj.view.getSelectedNode();
            hdfPath = node.Tag;
            e = obj.Experiment.getByPath(hdfPath);
            assignin('base', node.Text, e);
        end
        
        function onViewKeyPress(obj, ~, evt)
            if ismember(evt.data.Key, {'c', 'x'})
                node = obj.view.getSelectedNode();
                if ~isempty(node)
                    node.collapse();
                end
            end

            if contains(evt.data.Modifier, 'control')
                switch evt.data.Key
                    case 'equal'
                        obj.view.changeFontSize(1);
                    case 'hyphen'
                        obj.view.changeFontSize(-1);
                    case 'rightarrow'
                        obj.view.resizeFigure(100, 0);
                    case 'leftarrow'
                        obj.view.resizeFigure(-100, 0);
                end
            end
        end
    end

    methods (Static)
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

        function attributes = att2display(attributes)
            k = attributes.keys;
            for i = 1:numel(k)
                iValue = attributes(k{i});
                if iscell(iValue)
                    attributes(k{i}) = iValue{:};
                elseif isnumeric(iValue) && numel(iValue) == 1
                    attributes(k{i}) = num2str(iValue);
                end
            end
        end
    end
end 