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
%
% Events:
%   N/A

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties 
        QueryManager        
        matchedEntities     
    end

    properties
        figureHandle        matlab.ui.Figure

        codePanel
        exptPanel
        filterPanel 
        matchPanel
    end

    % QueryManager interface
    properties (Dependent)
        Experiments         aod.persistent.Experiment
        numExperiments      double  {mustBeInteger}
        allEntities         
        numEntities         double  {mustBeInteger}
        numFilters          double  {mustBeInteger}
        hdfFiles            string 
    end

    properties (Hidden)
        dataGroup           matlab.ui.container.TabGroup
        exptTab             matlab.ui.container.Tab
        filterTab           matlab.ui.container.Tab 

        resultGroup         matlab.ui.container.TabGroup
        codeTab             matlab.ui.container.Tab 
        matchTab            matlab.ui.container.Tab
    end

    methods
        function obj = QueryView(varargin)
            obj = obj@aod.app.Component([], [], varargin{:});

            obj.setHandler(aod.app.query.handlers.QueryView(obj));
        end
    end

    % Dependent set/get methods
    methods 

        function value = get.Experiments(obj)
            value = obj.QueryManager.Experiments;
        end

        function value = get.allEntities(obj)
            value = obj.QueryManager.entityTable;
        end

        function value = get.numEntities(obj)
            value = obj.QueryManager.numEntities;
        end

        function value = get.numFilters(obj)
            value = obj.QueryManager.numFilters;
        end

        function value = get.numExperiments(obj)
            value = obj.QueryManager.numFiles;
        end

        function value = get.hdfFiles(obj)
            value = obj.QueryManager.hdfName;
        end
    end

    % Callback methods
    methods (Access = private)
        function onTab_Changed(obj, src, evt)
            evtHidden = aod.app.Event("TabHidden", src);
            evtActive = aod.app.Event("TabActive", src);

            if strcmp(evt.NewValue.Title, 'Code')
                obj.codePanel.update(evtActive);
                obj.matchPanel.update(evtHidden);
            elseif strcmp(evt.NewValue.Title, 'Entities')
                obj.matchPanel.update(evtActive);
                obj.codePanel.update(evtHidden);
            end
        end

        function onClose_Figure(obj, ~, ~)
            delete(obj.figureHandle);
        end
    end

    % Component methods (public)
    methods
        function update(obj, evt)
            if ismember(evt.EventType, ["PushFilter", "PullFilter",...
                    "EditFilter", "ClearFilters",... 
                    "AddExperiment", "RemoveExperiment"])
                obj.collectMatchedEntities();
            end

            obj.updateChildren(evt);
        end
    end

    % Component methods (protected)
    methods (Access = protected)
        function value = specifyChildren(obj)
            value = [obj.exptPanel; obj.filterPanel;...
                     obj.codePanel; obj.matchPanel];
        end

        function willGo(obj, varargin)
            obj.QueryManager = aod.api.QueryManager(varargin{:});
            obj.collectMatchedEntities();
        end
        
        function createUi(obj)
            obj.figureHandle = uifigure(...
                "CloseRequestFcn", @obj.onClose_Figure);
            obj.figureHandle.Position(3) = obj.figureHandle.Position(3) + 300;
            if ispref('AOData', 'Development') && getpref('AOData', 'Development')
                %! Development
                obj.figureHandle.Position(1:2) = [-1000 127];
            end

            mainLayout = uigridlayout(obj.figureHandle, [1 2],...
                "ColumnWidth", {"1.6x", "1x"}, "ColumnSpacing", 2,...
                "Padding", [3 3 3 3]);

            obj.dataGroup = uitabgroup(mainLayout);
            obj.exptTab = uitab(obj.dataGroup,...
                "Title", "Experiments");
            obj.exptPanel = aod.app.query.ExperimentPanel(obj, obj.exptTab);
            obj.filterTab = uitab(obj.dataGroup,...
                "Title", "Filters");
            obj.filterPanel = aod.app.query.FilterPanel(obj, obj.filterTab);
            
            obj.resultGroup = uitabgroup(mainLayout, ...
                "SelectionChangedFcn", @obj.onTab_Changed);
            obj.matchTab = uitab(obj.resultGroup,... 
                "Title", "Entities");
            obj.matchPanel = aod.app.query.MatchPanel(obj, obj.matchTab);
            obj.codeTab = uitab(obj.resultGroup, ...
                "Title", "Code");
            obj.codePanel = aod.app.query.CodePanel(obj, obj.codeTab);
        end 

        function close(obj)
            delete(obj.figureHandle);
        end
    end


    methods (Access = private)
        function collectMatchedEntities(obj)
            if obj.numExperiments == 0
                obj.matchedEntities = table.empty();
                return 
            end

            if obj.numFilters == 0
                obj.matchedEntities = obj.QueryManager.entityTable;
            else
                [~, obj.matchedEntities] = obj.QueryManager.filter();
            end 
        end
    end
end 