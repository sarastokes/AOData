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
        %Experiments         aod.persistent.Experiment
        QueryManager        aod.api.QueryManager = aod.api.QueryManager([]);
    end

    properties
        figureHandle        matlab.ui.Figure

        codePanel
        exptPanel
        filterPanel 
        matchPanel
    end

    properties (Dependent)
        Experiments         aod.persistent.Experiment
        numExperiments      double  {mustBeInteger}
        numFilters          double  {mustBeInteger}
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

            obj.setHandler(aod.app.query.handlers.QueryView(obj));

            obj.isInverted = false;
        end

        function value = get.Experiments(obj)
            value = obj.QueryManager.Experiments;
        end

        function value = get.numFilters(obj)
            value = obj.QueryManager.numFilters;
        end

        function value = get.numExperiments(obj)
            value = obj.QueryManager.numFiles;
        end
    end

    methods (Access = protected)
        function value = specifyChildren(obj)
            value = [obj.exptPanel; obj.filterPanel;...
                     obj.codePanel; obj.matchPanel];
        end
        
        function createUi(obj)
            obj.figureHandle = uifigure();
            obj.figureHandle.Position(3) = obj.figureHandle.Position(3) + 300;
            if ispref('AOData', 'Development') && getpref('AOData', 'Development')
                %! Development
                obj.figureHandle.Position(1:2) = [10 392];
            end

            mainLayout = uigridlayout(obj.figureHandle, [1 2],...
                "ColumnWidth", {"1.6x", "1x"}, "ColumnSpacing", 2,...
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
            obj.codePanel = aod.app.query.CodePanel2(obj, obj.codeTab);
        end

        function onTab_Changed(obj, src, evt)
            evtHidden = aod.app.Event("TabHidden", src);
            evtActive = aod.app.Event("TabActive", src);
            
            if strcmp(evt.NewValue.Title, 'Code')
                obj.codePanel.update(evtActive);
                obj.matchPanel.update(evtHidden);
            elseif strcmp(evt.NewValue.Title, 'Matches')
                obj.matchPanel.update(evtActive);
                obj.codePanel.update(evtHidden);
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