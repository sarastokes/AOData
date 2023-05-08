classdef QueryView < aod.app.Component
% AOQuery user interface
%
% Superclass:
%   aod.app.Component
%
% Constructor:
%   obj = aod.app.views.QueryView()
%
% Children:
%   CodePanel, ExperimentPanel, MatchPanel, FilterPanel

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    events
        ChangedFilters
    end

    properties 
        Experiments         aod.persistent.Experiment
        QueryManager
    end

    properties
        figureHandle        matlab.ui.Figure

        codePanel
        exptPanel
        filterPanel 
        matchPanel
    end

    properties (Dependent)
        numExperiments      double  {mustBeInteger}
        Filters 
    end

    properties (Hidden)
        dataGroup           matlab.ui.container.TabGroup
        exptTab             matlab.ui.container.Tab
        filterTab           matlab.ui.container.Tab 

        resultGroup         matlab.ui.container.TabGroup
        codeTab             matlab.ui.container.Tab 
        matchTab            matlab.ui.container.Tab

        isInverted          logical
    end

    methods
        function obj = QueryView()
            obj = obj@aod.app.Component([], []);

            obj.setHandler(aod.app.query.QueryViewHandler(obj));
            obj.isInverted = false;
        end

        function value = get.numExperiments(obj)
            value = numel(obj.Experiments);
        end

        function value = get.Filters(obj)
            if isempty(obj.filterPanel.Filters)
                value = [];
                return 
            end

            idx = arrayfun(@(x) x.isReady, obj.filterPanel.Filters);
            value = obj.filterPanel.Filters(idx);
        end

        function refilter(obj)
        end
    end

    methods (Access = protected)
        function value = specifyChildren(obj)
            value = [obj.exptPanel; obj.filterPanel;...
                     obj.codePanel; obj.matchPanel];
        end
        
        function createUi(obj)
            obj.figureHandle = uifigure();
            obj.figureHandle.Position(3) = obj.figureHandle.Position(3) + 250;
            %! Development
            obj.figureHandle.Position(1:2) = [10 392];

            mainLayout = uigridlayout(obj.figureHandle, [1 2],...
                "ColumnWidth", {"1.8x", "1x"}, "ColumnSpacing", 3,...
                "Padding", [3 3 3 3]);

            obj.dataGroup = uitabgroup(mainLayout);
            obj.exptTab = uitab(obj.dataGroup,...
                "Title", "Expt");
            obj.exptPanel = aod.app.query.ExperimentPanel(obj, obj.exptTab);
            obj.filterTab = uitab(obj.dataGroup,...
                "Title", "Filters");
            obj.filterPanel = aod.app.query.FilterPanel(obj, obj.filterTab);
            
            obj.resultGroup = uitabgroup(mainLayout, ...
                "SelectionChangedFcn", @obj.onTab_Changed);
            obj.matchTab = uitab(obj.resultGroup,... 
                "Title", "Matches");
            obj.matchPanel = aod.app.query.MatchPanel(obj, obj.matchTab);
            obj.codeTab = uitab(obj.resultGroup, ...
                "Title", "Code");
            obj.codePanel = aod.app.query.CodePanel(obj, obj.codeTab);
        end

        function onTab_Changed(obj, ~, evt)
            assignin('base', 'evt', evt);
            if strcmp(evt.NewValue.Title, 'Code')
                obj.codePanel.update();
            elseif strcmp(evt.NewValue.Title, 'Matches')
                obj.matchPanel.update();
            end
            
        end
    end

    methods 
        function invert(obj)
            obj.isInverted = ~obj.isInverted;

            if obj.isInverted
                bkgd = [0.1 0.1 0.15]-0.05;
                button = [0.14 0.14 0.19]-0.05;
                grid = [0.16 0.16 0.21]-0.05;
                text = [0.94 0.94 0.94];
                
            else
                bkgd = [1 1 1];
                button = [0.96 0.96 0.96];
                grid = [0.94 0.94 0.94];
                text = [0 0 0];
            end

            obj.figureHandle.Color = bkgd;
            set(findall(obj.figureHandle, 'Type', 'uitab'),...
                'BackgroundColor', grid, 'ForegroundColor', text);
            set(findall(obj.figureHandle, 'Type', 'uigridlayout'),...
                'BackgroundColor', grid);
            set(findall(obj.figureHandle, 'Type', 'uitextarea'),...
                'BackgroundColor', bkgd, 'FontColor', text);
            set(findall(obj.figureHandle, 'Type', 'uibutton'),...
                'BackgroundColor', button, 'FontColor', text);
            set(findall(obj.figureHandle, 'Type', 'uilabel'),...
                'BackgroundColor', 'none', 'FontColor', text);
        end
    end
end 