classdef ExperimentView < aod.app.UIView 
% EXPERIMENTVIEW
%
% Parent:
%   aod.app.UIView
%
% Syntax:
%   obj = ExperimentView()
%
% See also:
%   aod.app.presenters.ExperimentPresenter
% -------------------------------------------------------------------------
    events 
        NodeSelected 
        NodeExpanded 
        NodeDoubleClicked
        LinkFollowed
        SendNodeToBase
        CopyHdfAddress
    end

    properties 
        Tree 
        Attributes          matlab.ui.control.Table
        ContextMenu         matlab.ui.container.ContextMenu

        AxesPanel 
        TablePanel 
        TextPanel
        LinkPanel

        LinkPanelText       matlab.ui.control.TextArea
    end

    properties (Access = private)
        containerIcon
    end

    properties (Hidden, Constant)
        CONTAINER_STYLE = uistyle("FontAngle", "italic");
        SYSTEM_STYLE = uistyle('FontColor', [0.4 0.4 0.4]);
        ICON_DIR = [fileparts(fileparts(mfilename('fullpath'))), filesep,...
            '+icons', filesep];
    end

    methods
        function obj = ExperimentView()
            obj = obj@aod.app.UIView();

            obj.containerIcon = im2uint8(lighten(im2double(...
                imread([obj.ICON_DIR, 'folder.png'])), 0.45));
        end

        function fh = getFigure(obj)
            % For development, remove later
            fh = obj.figureHandle;
        end
    end

    methods 
        function resetDisplay(obj)
            cla(obj.AxesPanel, 'reset');
            obj.AxesPanel.Visible = 'off';

            obj.TextPanel.Value = '';
            obj.TextPanel.Visible = 'off';

            obj.TablePanel.Data = [];
            obj.TablePanel.Visible = 'off';

            obj.LinkPanelText.Value = "";
            obj.LinkPanel.Visible = 'off';

            removeStyle(obj.Attributes);
            obj.Attributes.Data = [];
        end

        function node = getSelectedNode(obj)
            % GETSELECTEDNODES
            %
            % Description:
            %   Convenience function for accessing selected node without
            %   knowing how it is represented in the view
            % -------------------------------------------------------------
            node = obj.Tree.SelectedNodes;
        end

        function setAttributeTable(obj, data)
            % SETATTRIBUTETABLE
            %
            % Description:
            %   Add attributes (as container.Map) to the attribute table
            % -------------------------------------------------------------
            disp('hey')
            obj.Attributes.ColumnName = {'Attribute', 'Value'};
            if nargin > 1
                obj.Attributes.Data = data;
                rowIdx = find(cellfun(@(x) ismember(x, {'UUID', 'label', 'entityType', 'Class'}), data{:, 1}));
                addStyle(obj.Attributes, obj.SYSTEM_STYLE, 'Row', rowIdx);
            end
        end
    end

    % Panel display methods
    methods 
        function setLinkPanelView(obj, linkValue)
            obj.LinkPanel.Visible = 'on';
            obj.LinkPanelText.Value = linkValue;
        end
    end

    % New node methods
    methods 
        function g = populateEntityNode(obj, hdfPath, parentNode)
            % POPULATEENTITYNODE
            %
            % Description:
            %   Create a new node representing an HDF group for an entity
            % -------------------------------------------------------------
            if nargin < 3
                parentPath = aod.h5.HDF5.getPathParent(hdfPath);
                if parentPath == "/"
                    parentNode = obj.Tree;
                else
                    parentNode = findobj(obj.figureHandle, "Tag", parentPath);
                end
            end
            assignin('base','parentNode',parentNode);
            nodeData = struct('LoadState', aod.app.GroupLoadState.NAME,...
                'NodeType', 'Entity', 'Attributes', containers.Map());
            g = uitreenode(parentNode,...
                'Text', aod.h5.HDF5.getPathEnd(hdfPath),...
                'Icon', [obj.ICON_DIR, 'folder.png'],...
                'NodeData', nodeData,...
                'Tag', hdfPath);
            assignin('base','g',g);
            % Include so expand option is available for later loading
            uitreenode(g,...
                'Text', 'Placeholder');
            %obj.addContextMenu(g);
        end

        function populateContainerNode(obj, hdfPath, parentNode)
            % POPULATECONTAINERNODE
            %
            % Description:
            %   Create a new node representing an HDF group representing an
            %   entity container
            % -------------------------------------------------------------
            if nargin < 3
                parentNode = findobj(obj.figureHandle, "Tag",...
                    aod.h5.HDF5.getPathParent(hdfPath));
            elseif ~isa(parentNode, 'matlab.ui.container.TreeNode')
                parentNode = findobj(obj.figureHandle, "Tag", parentNode);
            end
            nodeData = struct('NodeType', 'Container',...
                'LoadState', aod.app.GroupLoadState.NAME,...
                'Attributes', containers.Map());
            g = uitreenode(parentNode,...
                'Text', aod.h5.HDF5.getPathEnd(hdfPath),...
                'Icon', obj.containerIcon,...
                'NodeData', nodeData,...
                'Tag', hdfPath);
            addStyle(obj.Tree, obj.CONTAINER_STYLE, "Node", g);
            %obj.addContextMenu(g);
        end

        function g = makeEntityNode(obj, parent, nodeName, hdfPath, data)
            g = uitreenode(parent,...
                'Text', nodeName,...
                'Icon', [obj.ICON_DIR, 'folder.png'],...
                'Tag', hdfPath,...
                'NodeData', data);
        end

        function makePlaceholderNode(obj, parent) %#ok<INUSD> 
            uitreenode(parent,...
                'Text', 'Placeholder');
        end

        function node = formatContainerNode(obj, node)
            node.Icon = im2uint8(lighten(im2double(...
                imread([obj.ICON_DIR, 'folder.png'])), 0.45));
            addStyle(obj.Tree, obj.CONTAINER_STYLE, "node", node);
        end

        function g = makeDatasetNode(obj, parent, dsetName, hdfPath, data) %#ok<INUSD> 
            g = uitreenode(parent,...
                'Text', dsetName,...
                'Icon', data.AONode.getIconPath(),...
                'Tag', hdfPath,...
                'NodeData', data);
        end

        function makeLinkNode(obj, parentNode, linkName, linkValue)
            % MAKELINKNODE
            %
            % Description:
            %   Create a new node representing an HDF link
            % -------------------------------------------------------------
            linkData = struct('NodeType', 'link', 'LinkPath', linkValue);
            
            g = uitreenode(parentNode,...
                'Text', linkName,...
                'Icon', [obj.ICON_DIR, 'link.png'],...
                'Tag', aod.h5.HDF5.buildPath(parentNode.Tag, linkName),...
                'NodeData', linkData);
            obj.addContextMenu(g);
        end

        function addContextMenu(obj, node)
            % ADDCONTEXTMENU
            % 
            % Description:
            %   Adds context menu to the node
            % -------------------------------------------------------------
            node.ContextMenu = obj.ContextMenu;
        end
    end

    % Callback methods
    methods
        function onNodeExpanded(obj, ~, evt)
            % ONNODEEXPANDED
            %   
            % Description:
            %   Make private node information accessible outside the view
            % -------------------------------------------------------------
            obj.expandedNode = evt.Node;
            notify(obj, 'NodeExpanded');
        end
    end

    % Initialization methods
    methods
        function setTitle(obj, str)
            arguments
                obj
                str         char
            end
            obj.figureHandle.Name = str;
        end

        function createUi(obj)
            % CREATEUI
            %
            % Description:
            %   Initialize the components of the view
            % -------------------------------------------------------------
            obj.figureHandle.Position(3:4) = [500 450];
            movegui(obj.figureHandle, 'center');

            mainLayout = uigridlayout(obj.figureHandle);
            mainLayout.RowHeight = {'1.5x', '1x'};
            mainLayout.ColumnWidth = {'1x', '1.25x'};

            obj.Tree = uitree(mainLayout,...
                'SelectionChangedFcn', @(h,d)notify(obj, 'NodeSelected'),...
                'NodeExpandedFcn', @(h,d)notify(obj, 'NodeExpanded', appbox.EventData(d)));
            obj.Tree.Layout.Column = 1;
            obj.Tree.Layout.Row = [1 2];

            obj.Attributes = uitable(mainLayout,...
                'FontSize', 12);
            obj.Attributes.Layout.Column = 2;
            obj.Attributes.Layout.Row = 2;

            obj.AxesPanel = uiaxes(mainLayout, 'Visible', 'off');
            obj.AxesPanel.Layout.Column = 2;
            obj.AxesPanel.Layout.Row = 1;
    
            obj.TextPanel = uitextarea(mainLayout,...
                'Visible', 'off',...
                'BackgroundColor', 'w');
            obj.TextPanel.Layout.Column = 2;
            obj.TextPanel.Layout.Row = 1;

            obj.TablePanel = uitable(mainLayout,...
                'Visible', 'off');
            obj.TablePanel.Layout.Column = 2;
            obj.TablePanel.Layout.Row = 1;

            obj.LinkPanel = uipanel(mainLayout,...
                'Visible', 'off');
            obj.LinkPanel.Layout.Column = 2;
            obj.LinkPanel.Layout.Row = 1;
            g = uigridlayout(obj.LinkPanel, [2 1]);
            g.RowHeight = {'1x', 35};
            obj.LinkPanelText = uitextarea(g,...
                'BackgroundColor', 'w');
            uibutton(g, 'Text', 'Go to link',...
                'ButtonPushedFcn', @(h,d)notify(obj, 'LinkFollowed'));

            obj.ContextMenu = uicontextmenu(obj.figureHandle);
            uimenu(obj.ContextMenu,...
                'Label', 'Send to workspace',...
                'Callback', @(h, d)notify(obj, 'SendNodeToBase'));
            uimenu(obj.ContextMenu,...
                'Label', 'Copy hdf address',...
                'Callback', @(h,d)notify(obj, 'CopyHdfAddress'));
        end
    end

    methods (Static)
        function groupName = getGroupName(fullName)
            txt = strsplit(fullName, '/');
            groupName = txt{end};
        end
    end
end 