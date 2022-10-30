classdef QueryPresenter < appbox.Presenter 

    properties
        Experiment 
        filterIdx
        allClassNames
        allGroupNames
    end

    properties (Hidden, Dependent)
        classNames
        groupNames
    end

    properties (Hidden, Constant)
        FILTER_TYPES = ["", "Entity", "Class", "Parameter", "Property"];
    end

    methods
        function obj = QueryPresenter(experiment, view)
            if nargin < 2
                view = aod.app.views.QueryView();
            end
            obj = obj@appbox.Presenter(view);

            if nargin == 0 || isempty(experiment)
                experiment = obj.view.showGetFile('Chose an AOData H5 file', '*.h5');
                if isempty(experiment)
                    warning("QueryPresenter:NoAODataFile",...
                        "No experiment provided, cancelling app");
                    obj.view.close();
                    return
                end
                obj.Experiment = loadExperiment(experiment);
            else
                obj.Experiment = experiment;
            end

            obj.go();
        end

        function value = get.groupNames(obj)
            value = obj.allGroupNames(obj.filterIdx);
        end

        function value = get.classNames(obj)
            value = obj.allClassNames(obj.filterIdx);
        end
    end

    % For development, remove later
    methods
        function v = getView(obj)
            v = obj.view;
        end

        function fh = getFigure(obj)
            fh = obj.figureHandle;
        end
    end

    methods (Access = protected)
        function willGo(obj)
            obj.populateGroupNames();

            obj.view.setGroupNames(obj.allGroupNames);
            obj.view.setGroupCount(numel(obj.allGroupNames), numel(obj.groupNames));
            obj.allClassNames = obj.populateClasses();

            obj.view.createDropdown(obj.view.filterGrid, [2 1],...
                obj.FILTER_TYPES, 'FilterSelected');
            
        end

        function bind(obj)
            bind@appbox.Presenter(obj);

            v = obj.view;
            obj.addListener(v, 'FilterSelected', @obj.onViewSelectedFilter);
            obj.addListener(v, 'FilterAdded', @obj.onViewAddedFilter);
            obj.addListener(v, 'FilterRemoved', @obj.onViewRemovedFilter);
            obj.addListener(v, 'EntityFilterChosen', @obj.onViewEntityFilterChosen);
            obj.addListener(v, 'ClassFilterChosen', @obj.onViewClassFilterChosen);

            obj.addListener(v, 'QueryReset', @obj.onViewResetQuery);
            obj.addListener(v, 'GroupsChanged', @obj.onViewChangedGroups);
            obj.addListener(v, 'GroupSelected', @obj.onViewSelectedGroup);
        end
    end

    % Callbacks
    methods (Access = private)
        function onViewChangedGroups(obj, ~, ~)
            obj.view.setGroupCount(...
                numel(obj.groupNames), numel(obj.allGroupNames));
        end

        function onViewSelectedGroup(obj, ~, evt)
            entity = obj.Experiment.getByPath(evt.data.Value);
            obj.view.displayEntity(entity);
        end

        function onViewSelectedFilter(obj, ~, evt)
            if evt.data.Value == ""
                return
            end
            if evt.data.Source.Layout.Column == 1
                obj.parseFilterLevel1(evt);
            elseif evt.data.Source.Layout.Column == 2
                obj.parseFilterLevel2(evt);
            end
        end

        function onViewEntityFilterChosen(obj, ~, evt)
            % Select groups that match the entity
            for i = 1:numel(obj.allGroupNames)
                if obj.filterIdx(i)
                    entityType = h5readatt(obj.Experiment.hdfName,...
                    obj.allGroupNames(i), 'EntityType');
                    obj.filterIdx(i) = strcmpi(entityType, evt.data.Value);
                end
            end
            obj.view.setGroupNames(obj.groupNames);
            obj.view.setGroupCount(numel(obj.groupNames), numel(obj.allGroupNames));
        end

        function onViewClassFilterChosen(obj, ~, evt)
            % Select groups that match the class
        end

        function onViewAddedFilter(obj, ~, ~)
        end

        function onViewRemovedFilter(obj, ~, ~)
        end

        function onViewResetQuery(obj, ~, ~)
        end
    end

    methods (Access = private)
        function populateGroupNames(obj)
            names = aod.h5.HDF5.collectGroups(obj.Experiment.hdfName);
            containerNames = aod.core.EntityTypes.allContainerNames();
            for i = 1:numel(containerNames)
                names = names(~endsWith(names, containerNames(i)));
            end
            obj.allGroupNames = names;
            obj.filterIdx = true(size(obj.allGroupNames));
        end

        function classNames = populateClasses(obj)
            classNames = repmat("", [numel(obj.groupNames), 1]);
            for i = 1:numel(obj.groupNames)
                classNames(i) = h5readatt(obj.Experiment.hdfName,...
                    obj.groupNames(i), 'Class');
            end
        end
    end

    % Parsing methods
    methods (Access = private)
        function parseFilterLevel2(obj, evt)
        end

        function parseFilterLevel1(obj, evt)
            newLocation = [evt.data.Source.Layout.Row, 2];
            switch evt.data.Value
                case "Entity"
                    obj.view.createDropdown(evt.data.Source.Parent, newLocation,... 
                        [""; enumStr('aod.core.EntityTypes')],...
                        'EntityFilterChosen');
                case "Class"
                    obj.view.createDropdown(evt.data.Source.Parent, newLocation,...
                        ["", unique(obj.classNames)],...
                        'ClassFilterChosen');
            end
        end
    end
end 