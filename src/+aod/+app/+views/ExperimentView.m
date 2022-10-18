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

        function selectNode(obj, node)
            obj.Tree.SelectedNodes = node;
            notify(obj, 'NodeSelected');
        end

        function node = path2node(obj, hdfPath)
            node = findobj(obj.Tree, 'Tag', hdfPath);
        end

        function showNode(obj, node)
            scroll(obj.Tree, node);
        end
    end

    % Node-specific display methods
    methods 
        function setDataDisplayPanel(obj, displayType, data)
            switch displayType
                case 'Text'
                    obj.setTextPanelView(data);
                case 'Table'
                    obj.setTablePanelView(data);
            end
        end

        function setAttributeTable(obj, data)
            % SETATTRIBUTETABLE
            %
            % Description:
            %   Add attributes (as container.Map) to the attribute table
            % -------------------------------------------------------------
            obj.Attributes.ColumnName = {'Attribute', 'Value'};
            if nargin > 1
                obj.Attributes.Data = data;
                systemAttributes = {'UUID', 'label', 'entityType', 'Class', 'Format'};
                rowIdx = find(cellfun(@(x) ismember(x, systemAttributes), data{:, 1}));
                addStyle(obj.Attributes, obj.SYSTEM_STYLE, 'Row', rowIdx);
            end
        end

        function setLinkPanelView(obj, linkValue)
            obj.LinkPanel.Visible = 'on';
            obj.LinkPanelText.Value = linkValue;
        end

        function setTextPanelView(obj, txt)
            obj.TextPanel.Visible = 'on';
            obj.TextPanel.Value = txt;
        end

        function setTablePanelView(obj, data)
            obj.TablePanel.Visible = 'on';
            if istable(data)
                obj.TablePanel.Data = data.Data;
                obj.TablePanel.ColumnNames = data.Data.Properties.VariableNames;
            else
                obj.TablePanel.Data = data;
            end
        end
    end

    % New node methods
    methods 
        function g = makeEntityNode(obj, parent, nodeName, hdfPath, data)
            g = uitreenode(parent,...
                'Text', nodeName,...
                'Icon', [obj.ICON_DIR, 'folder.png'],...
                'Tag', hdfPath,...
                'NodeData', data);
        end

        function g = makeDatasetNode(obj, parent, dsetName, hdfPath, data) %#ok<INUSD> 
            g = uitreenode(parent,...
                'Text', dsetName,...
                'Icon', data.AONode.getIconPath(),...
                'Tag', hdfPath,...
                'NodeData', data);
        end

        function makeLinkNode(obj, parentNode, linkName, hdfPath, linkValue)
            % MAKELINKNODE
            %
            % Description:
            %   Create a new node representing an HDF link
            % -------------------------------------------------------------
            linkData = struct('NodeType', 'link', 'LinkPath', linkValue,...
                'H5Node', aod.app.H5NodeTypes.LINK,...
                'AONode', aod.app.AONodeTypes.LINK);
            
            g = uitreenode(parentNode,...
                'Text', linkName,...
                'Icon', [obj.ICON_DIR, 'link.png'],...
                'Tag', hdfPath,...
                'NodeData', linkData);
            obj.addContextMenu(g);
        end

        function makePlaceholderNode(obj, parent) %#ok<INUSD> 
            uitreenode(parent,...
                'Text', 'Placeholder');
        end

        function node = formatContainerNode(obj, node)
            node.Icon = aod.app.AONodeTypes.CONTAINER.getIconPath();
            addStyle(obj.Tree, obj.CONTAINER_STYLE, "node", node);
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