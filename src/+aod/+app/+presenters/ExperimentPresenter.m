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

        function v = getView(obj)
            % For development, remove later
            v = obj.view;
        end
    end

    methods (Access = protected)
        function willGo(obj)
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
            S = struct('Attributes', nodeParams, 'HdfPath', group.Name,...
                'NodeType', nodeType);
            g = uitreenode(parentNode, ...
                'Text', obj.getGroupName(group.Name),...
                'Icon', [obj.ICON_DIR, 'folder.png'],...
                'NodeData', S);
            if strcmp(nodeType, 'container')
                g.Icon = im2uint8(lighten(im2double(imread([obj.ICON_DIR, 'folder.png'])), 0.45));
                addStyle(obj.view.Tree, obj.CONTAINER_STYLE, "node", g);
            end

            S = h5info(obj.Experiment.hdfName, group.Name);

            if ~isempty(S.Groups)
                for i = 1:numel(S.Groups)
                    obj.parseGroup(S.Groups(i), g);
                end
            end
        end

        function nodeData = populateNewNodeInfo(obj, hdfPath)
            if endsWith(hdfPath, 'Container')
                nodeType = 'Container';
                % Load attributes here
            else
                entity = obj.Experiment.factory.create(hdfPath);
                nodeType = 'Entity'; %entity.entityType;
            end
            nodeData = struct('NodeType', nodeType, 'HdfPath', hdfPath);
        end

        function nodeData = populateContainerInfo(obj, hdfPath)
            nodeData = struct('NodeType', 'Container', 'HdfPath', hdfPath);
        end
    end

    % Callbacks
    methods (Access = private)
        function onViewSelectedNode(obj, ~, ~)
            obj.view.resetDisplay();
            node = obj.view.getSelectedNode();
            assignin('base', 'node', node);
            
            if ~isempty(node.NodeData.Attributes)
                k = node.NodeData.Attributes.keys;
                v = node.NodeData.Attributes.values;
                data = table(k', v');
                obj.view.setAttributeTable(data);
            end
        end

        function onViewExpandedNode(obj, ~, ~)
            if obj.DEBUG 
                return
            end
            node = obj.view.getSelectedNode();
            % Check to see whether node is container or not
            if strcmp(node.nodeData.nodeType, 'Container')
                entity = obj.getParentPath(node.NodeData.hdfPath);
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
            switch evt.Character
                case 'c'
                    node = obj.view.getSelectedNode();
                    node.collapse();
                case 'x'
                    node = obj.view.getSelectedNode();
                    node.collapse();
                    node.Parent.collapse();
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