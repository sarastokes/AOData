classdef ExperimentView < aod.app.UIView 
% UI for AODataViewer
%
% Parent:
%   aod.app.UIView
%
% Syntax:
%   obj = aod.app.views.ExperimentView()
%
% See Also:
%   aod.app.presenters.ExperimentPresenter, AODataViewer

% By Sara Patterson, 2023 (AOData)
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

    properties (Hidden, Constant)
        % Style for groups that act as entity containers
        CONTAINER_STYLE = uistyle("FontAngle", "italic");
        % Style for system attributes
        SYSTEM_STYLE = uistyle('FontColor', [0.4 0.4 0.4]);
    end

    methods
        function obj = ExperimentView()
            obj = obj@aod.app.UIView();
        end

        function fh = getFigure(obj)
            % Useful for development, remove later
            fh = obj.figureHandle;
        end
    end

    methods 
        function resetDisplay(obj)
            % Reset display before processing a newly clicked node
            % -------------------------------------------------------------

            % Empty the table but keep visible (all nodes can have atts)
            removeStyle(obj.Attributes);
            obj.Attributes.Data = [];

            % Clear contents of data displays
            cla(obj.AxesPanel, 'reset');
            obj.TextPanel.Value = '';
            obj.TablePanel.Data = [];
            obj.LinkPanelText.Value = "";

            % Hide the various data displays
            obj.AxesPanel.Visible = 'off';
            obj.TextPanel.Visible = 'off';
            obj.TablePanel.Visible = 'off';
            obj.LinkPanel.Visible = 'off';

        end

        function node = getSelectedNode(obj)
            % Get currently selected node in view
            %
            % Description:
            %   Convenience function for accessing selected node without
            %   knowing how it is represented in the view
            % -------------------------------------------------------------
            node = obj.Tree.SelectedNodes;
        end

        function node = path2node(obj, hdfPath)
            % Get the node corresponding to a specific HDF5 path
            if strcmp(hdfPath, '/')
                node = obj.Tree;
            else
                node = findobj(obj.Tree, 'Tag', hdfPath);
            end
        end

    end

    % Generic display modification
    methods
        function selectNode(obj, node)
            % Select a specific node 

            obj.Tree.SelectedNodes = node;
            notify(obj, 'NodeSelected');
        end

        function showNode(obj, node)
            % Scroll to a specific node
            scroll(obj.Tree, node);
        end

        function changeFontSize(obj, modifier)
            obj.Tree.FontSize = obj.Tree.FontSize + modifier;
            obj.Attributes.FontSize = obj.Attributes.FontSize + modifier;
            obj.TextPanel.FontSize = obj.TextPanel.FontSize + modifier;
            obj.TablePanel.FontSize = obj.TablePanel.FontSize + modifier;
            obj.LinkPanelText.FontSize = obj.LinkPanelText.FontSize + modifier;
        end

        function resizeFigure(obj, x, y)
            % Resize the length or width of the figure window
            obj.figureHandle.Position(3) = obj.figureHandle.Position(3) + x;
            obj.figureHandle.Position(4) = obj.figureHandle.Position(4) + y;
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
            % Add attributes (as container.Map) to the attribute table
            % -------------------------------------------------------------
            obj.Attributes.ColumnName = {'Attribute', 'Value'};
            if nargin == 1
                return
            end

            % Gray out system attributes and sort to be last in table
            systemAttributes = aod.h5.getSystemAttributes();
            rowIdx = find(cellfun(@(x) ismember(x, systemAttributes), data{:, 1}));
            [rowIdx, idx] = sort(rowIdx);
            obj.Attributes.Data = data(idx,:);
            if ~isempty(rowIdx)
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
            if islogical(data)
                data = double(data);
            end
            obj.TablePanel.Data = data;
            if isnumeric(obj.TablePanel.Data) || istext(obj.TablePanel.Data)
                set(obj.TablePanel, "RowName", "numbered", ...
                    "ColumnName", "numbered");
            else
                set(obj.TablePanel, "RowName", data.Properties.RowNames,...
                    "ColumnName", data.Properties.VariableNames);
            end
        end

        function setAxesPanelView(obj)
            obj.AxesPanel.Visible = 'on';
            obj.AxesPanel.Toolbar.Visible = 'on';
        end
    end

    % New node methods
    methods 
        function g = makeEntityNode(obj, parent, nodeName, hdfPath, data)  
            if istext(parent)
                parent = obj.path2node(parent);
            end

            g = uitreenode(parent,...
                'Text', nodeName,...
                'Icon', data.AONode.getIconPath(),...
                'Tag', hdfPath,...
                'NodeData', data);
            if data.AONode == aod.app.util.AONodeTypes.CONTAINER 
                addStyle(obj.Tree, obj.CONTAINER_STYLE, "node", g);
            elseif data.AONode == aod.app.util.AONodeTypes.ENTITY 
                obj.addContextMenu(g);        
                % Leave a placeholder so node can be expanded, but don't
                % load the entity's datasets and links until requested
                obj.makePlaceholderNode(g);
            end
        end

        function g = makeDatasetNode(obj, parent, dsetName, hdfPath, data)   
            g = uitreenode(parent,...
                'Text', dsetName,...
                'Icon', data.AONode.getIconPath(),...
                'Tag', hdfPath,...
                'NodeData', data);
            obj.addContextMenu(g);
        end

        function makeLinkNode(obj, parentNode, linkName, hdfPath, data)
            % Create a new node representing an HDF link
            %
            % Inputs:
            %   parentNode          uitreenode
            %   linkName            char
            %   hdfPath             char
            %   nodeData            struct
            % -------------------------------------------------------------
                
            g = uitreenode(parentNode,...
                'Text', linkName,...
                'Icon', data.AONode.getIconPath(),...
                'Tag', hdfPath,...
                'NodeData', data);
            obj.addContextMenu(g);
        end

        function makePlaceholderNode(obj, parent)  %#ok<INUSL> 
            % Ensures groups with unloaded content are expandable
            uitreenode(parent,...
                'Text', 'Loading...');
        end

        function addContextMenu(obj, node)
            % Adds context menu to the node
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
            % Initialize the components of the view
            
            obj.figureHandle.Position(3:4) = [500 450];
            % movegui(obj.figureHandle, 'center'); too slow

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

            obj.initDataDisplayPanels(mainLayout, 1, 2);
            obj.initContextMenu();
        end

        function initDataDisplayPanels(obj, parent, row, col)
            obj.initAxesPanel(parent, row, col);
            obj.initTextPanel(parent, row, col);
            obj.initTablePanel(parent, row, col);
            obj.initLinkPanel(parent, row, col);
        end
        
        function initContextMenu(obj)
            obj.ContextMenu = uicontextmenu(obj.figureHandle);
            uimenu(obj.ContextMenu,...
                'Label', 'Send to workspace',...
                'Callback', @(h, d)notify(obj, 'SendNodeToBase'));
            uimenu(obj.ContextMenu,...
                'Label', 'Copy hdf address',...
                'Callback', @(h,d)notify(obj, 'CopyHdfAddress'));
        end
    end

    methods (Access = private)
        function initAxesPanel(obj, parent, row, col)
            obj.AxesPanel = uiaxes(parent,... 
                'Visible', 'off',...
                'Tag', 'DataPanel');
            obj.AxesPanel.Toolbar.Visible = 'off';
            obj.AxesPanel.Layout.Column = col;
            obj.AxesPanel.Layout.Row = row;
        end

        function initTextPanel(obj, parent, row, col)
            obj.TextPanel = uitextarea(parent,...
                'Editable', 'off',...
                'Tag', 'DataPanel',...
                'Visible', 'off',...
                'BackgroundColor', 'w');
            obj.TextPanel.Layout.Column = col;
            obj.TextPanel.Layout.Row = row;
        end

        function initTablePanel(obj, parent, row, col)
            obj.TablePanel = uitable(parent,...
                "FontSize", 12,... 
                "Tag", "DataPanel",... 
                "Visible", "off");
            addStyle(obj.TablePanel, uistyle("HorizontalAlignment", "center"));
            obj.TablePanel.Layout.Column = col;
            obj.TablePanel.Layout.Row = row;
        end

        function initLinkPanel(obj, parent, row, col)
            obj.LinkPanel = uipanel(parent,...
                'Tag', 'DataPanel',... 
                'Visible', 'off');
            obj.LinkPanel.Layout.Column = col;
            obj.LinkPanel.Layout.Row = row;

            g = uigridlayout(obj.LinkPanel, [2 1]);
            g.RowHeight = {'1x', 35};
            obj.LinkPanelText = uitextarea(g,...
                'Editable', 'off',...
                'BackgroundColor', 'w');
            uibutton(g, 'Text', 'Go to link',...
                'Tag', 'FollowLinkButton',...
                'ButtonPushedFcn', @(h,d)notify(obj, 'LinkFollowed'));
        end
    end

    methods (Static)
        function groupName = getGroupName(fullName)
            txt = strsplit(fullName, '/');
            groupName = txt{end};
        end
    end
end 