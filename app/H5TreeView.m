classdef H5TreeView < handle

    properties (Access = private)
        hdfFile
        figureHandle
        Tree
        Attributes
        Table
        Axes
        Text
        ContextMenu
    end

    properties (Hidden, Constant)
        CONTAINER_STYLE = uistyle("FontAngle", "italic");
        ICON_DIR = [fileparts(fileparts(mfilename('fullpath'))),...
            filesep, 'src', filesep, '+aod', filesep,... 
            '+app', filesep, '+icons', filesep];
    end
    
    methods
        function obj = H5TreeView(hdfFile)
            obj.hdfFile = hdfFile;

            obj.createUi();

            S = h5info(obj.hdfFile);

            if ~isempty(S.Groups)
                for i = 1:numel(S.Groups)
                    obj.parseGroup(S.Groups(i), obj.Tree);
                end
            end
            obj.parseDatasets('/', S, obj.Tree);
            obj.parseLinks(S, obj.Tree);
        end
    end
    
    methods (Access = private)

        function onKeyPress(obj, ~, evt)

            switch evt.Character
                case 'c'
                    node = obj.Tree.SelectedNodes;
                    node.collapse();
                case 'x'
                    node = obj.TreeSelectedNodes;
                    node.collapse();
                    node.Parent.collapse();
            end
        end
        
        function onNodeSelected(obj, src, ~)
            assignin('base', 'src', src);
            obj.resetDisplay();
            node = src.SelectedNodes;
            if isempty(node.NodeData)
                obj.Attributes.Data = [];
            else
                k = node.NodeData.keys;
                obj.Attributes.Data = table(k', node.NodeData.values');
                obj.Attributes.ColumnName = {'Attribute', 'Value'};
            end

            nodeType = aod.app.TreeNodeTypes.init(node.Tag);
            if nodeType == aod.app.TreeNodeTypes.GROUP || nodeType == ao.ui.TreeNodeTypes.GENERIC
                return
            end
            if nodeType.isText()
                obj.Text.Visible = 'on';
                nodeType.show(node.UserData, obj.Text);
            elseif nodeType.isTable()
                obj.Table.Visible = 'on';
                nodeType.show(node.UserData, obj.Table);
            else
                obj.Axes.Visible = 'on';
                nodeType.show(node.UserData, obj.Axes);
            end
        end

        function onSelected_SendDatasetToWorkspace(obj, ~, ~)
            assignin('base', 'NodeData', obj.Tree.SelectedNodes.UserData);
        end
    end

    % Initialization methods
    methods (Access = private)
        function resetDisplay(obj)
            cla(obj.Axes, 'reset');
            obj.Text.Value = '';
            obj.Table.Data = [];
            obj.Text.Visible = 'off';
            obj.Axes.Visible = 'off';
            obj.Table.Visible = 'off';
        end

        function parseGroup(obj, group, parentNode)
            nodeParams = obj.attributes2map(group.Attributes);

            g = uitreenode(parentNode,... 
                'Text', obj.getGroupName(group.Name),...
                'Icon',[obj.ICON_DIR, 'folder.png'],...
                'NodeData', nodeParams);
            if nodeParams.isKey('Class') && strcmpi(nodeParams('Class'), 'container')
                g.Icon = im2uint8(lighten(im2double(imread([obj.ICON_DIR, 'folder.png'])), 0.45));
                addStyle(obj.Tree, obj.CONTAINER_STYLE, "node", g);
            end
            S = h5info(obj.hdfFile, group.Name);

            obj.parseDatasets(group.Name, S, g);
            obj.parseLinks(S, g);

            if ~isempty(S.Groups)
                for i = 1:numel(S.Groups)
                    obj.parseGroup(S.Groups(i), g);
                end
            end
        end

        function parseDatasets(obj, groupName, S, parentNode)
            if isempty(S.Datasets)
                return;
            end
            for i = 1:numel(S.Datasets)
                dataObj = ao.io.H5DatasetPointer(obj.hdfFile, [groupName, '/', S.Datasets(i).Name]);
                nodeParams = obj.attributes2map(S.Datasets(i).Attributes);
                iNode = uitreenode(parentNode,...
                    'Text', S.Datasets(i).Name,...
                    'Icon', [obj.ICON_DIR, 'data.png'],...
                    'NodeData', nodeParams,...
                    'UserData', dataObj);
                if isKey(nodeParams, 'Class')
                    nodeClass = nodeParams('Class');

                    switch lower(nodeClass)
                        case 'datetime'
                            iNode.Icon = [obj.ICON_DIR, 'time.png'];
                        case {'double', 'logical', 'affine2d'}
                            iNode.Icon = [obj.ICON_DIR, 'data.png'];
                        case {'image', 'mask'}
                            iNode.Icon =[obj.ICON_DIR, 'image.png'];
                        case 'video'
                            iNode.Icon = [obj.ICON_DIR, 'video.png'];
                        case {'text', 'string', 'char'}
                            iNode.Icon = [obj.ICON_DIR, 'document.png'];
                        case 'externalfile'
                            iNode.Icon = [obj.ICON_DIR, 'export.png'];
                        case {'table', 'timeseries'}
                            iNode.Icon = [obj.ICON_DIR, 'table.png'];
                        otherwise
                            
                            iNode.Icon = [obj.ICON_DIR, 'data.png'];
                            warning('Unrecognized dataset class %s', nodeClass);
                    end
                    iNode.Tag = iNode.NodeData('Class');
                else
                    if strcmp(S.Datasets(i).Datatype.Class, 'H5T_STRING')
                        iNode.Tag = 'text';
                        iNode.Icon = [obj.ICON_DIR, 'document.png'];
                    end
                end
                iNode.ContextMenu = obj.ContextMenu;
            end
        end

        function parseLinks(obj, S, parentNode)
            % PARSELINKS
            if isempty(S.Links)
                return
            end
            for i = 1:numel(S.Links)
               uitreenode(parentNode,...
                   'Text', S.Links(i).Name,...
                   'Icon', [obj.ICON_DIR, 'link.png'],...
                   'NodeData', kv2map('Link', S.Links(i).Value{:}));
            end
        end
        
        function createUi(obj)
            obj.figureHandle = uifigure('Name', obj.hdfFile,...
                'WindowKeyPressFcn', @obj.onKeyPress);
            obj.figureHandle.Position(3:4) = [500 450];
            movegui(obj.figureHandle, 'center');

            obj.Tree = uitree(obj.figureHandle,... 
                'Position', [10 10 200 400], ...
                'SelectionChangedFcn', @obj.onNodeSelected);
            obj.Attributes = uitable(obj.figureHandle,... 
                'Position', [220 10 270 150]);
            obj.Axes = uiaxes(obj.figureHandle,...
                'Position', [220 170 270 250],...
                'BackgroundColor', 'w');
            obj.Text = uitextarea(obj.figureHandle,...
                'Position', [220 170 270 250],...
                'BackgroundColor', 'w');
            obj.Table = uitable(obj.figureHandle,...
                'Position', [220 170 270 250]);

            obj.ContextMenu = uicontextmenu(obj.figureHandle);
            uimenu(obj.ContextMenu,... 
                'Label', 'Send to workspace',...
                'Callback', @obj.onSelected_SendDatasetToWorkspace);
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