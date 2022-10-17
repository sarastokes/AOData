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
        SendNodeToBase
        CopyHdfAddress
    end

    properties 
        Tree 
        Attributes 
        Axes 
        Table 
        Text
        ContextMenu
    end

    properties (Hidden, Constant)
        CONTAINER_STYLE = uistyle("FontAngle", "italic");
        SYSTEM_STYLE = uistyle('FontColor', [0.4 0.4 0.4]);
        ICON_DIR = [fileparts(fileparts(mfilename('fullpath'))),...
            filesep, 'src', filesep, '+aod', filesep,... 
            '+app', filesep, '+icons', filesep];
    end

    methods
        function obj = ExperimentView()
            obj = obj@aod.app.UIView();
        end
    end

    methods 
        function node = getSelectedNode(obj)
            node = obj.Tree.SelectedNodes;
        end

        function setNodeView(obj)
        end

        function setAttributeTable(obj, data)
            obj.Attributes.ColumnName = {'Attribute', 'Value'};
            if nargin > 1
                obj.Attributes.Data = data;
            end
            rowIdx = find(cellfun(@(x) ismember(x, {'UUID', 'label', 'entityType', 'Class'}), data{:,1}));
            addStyle(obj.Attributes, obj.SYSTEM_STYLE, 'Row', rowIdx);
        end

        function resetDisplay(obj)
            cla(obj.Axes, 'reset');
            obj.Text.Value = '';
            obj.Table.Data = [];
            obj.Text.Visible = 'off';
            obj.Axes.Visible = 'off';
            obj.Table.Visible = 'off';
            removeStyle(obj.Attributes);
        end
    end

    methods 
        function createNode(obj, parent, entity, data)
            if isempty(parent)
                parent = obj.Tree;
            end
        end

        function setTitle(obj, str)
            arguments 
                obj
                str         char = ''
            end
            obj.figureHandle.Name = str;
        end

        function createUi(obj)
            obj.figureHandle.Position(3:4) = [500 450];
            movegui(obj.figureHandle, 'center');

            obj.Tree = uitree(obj.figureHandle,...
                'Position', [10 10 200 400],...
                'SelectionChangedFcn', @(h,d)notify(obj, 'NodeSelected'));
            obj.Attributes = uitable(obj.figureHandle,...
                'FontSize', 12,...
                'Position', [220 10 270 150]);

            viewPosition = [220 170 270 250];
            obj.Axes = uiaxes(obj.figureHandle,...
                'Position', viewPosition);
            obj.Text = uitextarea(obj.figureHandle,...
                'Position', viewPosition,...
                'BackgroundColor', 'w');
            obj.Table = uitable(obj.figureHandle,...
                'Position', viewPosition);

            obj.ContextMenu = uicontextmenu(obj.figureHandle);
            uimenu(obj.ContextMenu,...
                'Label', 'Send to workspace',...
                'Callback', @(h, d)notify(obj, 'SendNodeToBase'));
            uimenu(obj.ContextMenu,...
                'Label', 'CopyHdfAddress',...
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