classdef Experiment < aod.core.Entity
% An adaptive optics imaging session
%
% Description:
%   A single adaptive optics imaging experiment
%
% Parent:
%   aod.core.Entity
%
% Constructor:
%   obj = Experiment(name, experimentFolderPath, experimentDate)
%   obj = Experiment(name, experimentFolderPath, experimentDate,...
%       'Administrator', 'AdministratorName', 'Laboratory', 'LabName')
%
% Parameters:
%   Adminstrator                Person(s) who conducted the experiment
%   Laboratory                  Which lab the experiment occurred in
%
% Properties:
%   Epochs                      Container for experiment's Epochs
%   Source                      Container for experiment's Sources
%   Annotations                 Container for experiment's Annotations
%   Calibrations                Container for experiment's Calibrations
%   Systems                     Container for experiment's Systems
%   homeDirectory               File path for experiment files 
%   experimentDate              Date the experiment occurred
%   epochIDs                    List of epoch IDs in experiment
%
% Dependent properties:
%   numEpochs                   Number of epochs in experiment
% 
% Public methods:
%   setHomeDirectory(obj, filePath)
%   id = id2epoch(obj, epochID)
%   idx = id2index(obj, epochID)
%
%   add(obj, entity)
%   remove(obj, entityType, ID)
%   out = get(obj, entityType, varargin)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        % The experiment's data folder path
        homeDirectory  (1,:)    char
        % The date the experiment was performed 
        experimentDate (1, 1)   datetime
        % A table containing all git repositories and their status
        Code                    table
    end

    properties (SetAccess = protected)
        % Container for Experiment's Analyses
        Analyses                aod.core.Analysis  
        % Container for Experiment's Annotations     
        Annotations             aod.core.Annotation  
        % Container for Experiment's Calibrations   
        Calibrations            aod.core.Calibration  
        % Container for Experiment's Epochs
        Epochs                  aod.core.Epoch         
        % Container for Experiment's ExperimentDatasets
        ExperimentDatasets      aod.core.ExperimentDataset  
        % Container for Experiment's Sources
        Sources                 aod.core.Source      
        % Container for Experiment's Systems 
        Systems                 aod.core.System          
    end

    properties (Dependent)
        % The IDs of all epochs in the experiment
        epochIDs                double
        % The total number of epochs in the experiment
        numEpochs (1,1)         double      {mustBeInteger}
    end
    
    methods 
        function obj = Experiment(name, homeFolder, expDate, varargin)
            obj = obj@aod.core.Entity(name, varargin{:});

            obj.setHomeDirectory(homeFolder);
            obj.setDate(expDate);

            % Create a table of current status of all associated repos
            obj.appendGitHashes();
        end
    end

    % Dependent set/get methods
    methods
        function value = get.numEpochs(obj)
            value = numel(obj.Epochs);
        end

        function value = get.epochIDs(obj)
            if isempty(obj.Epochs)
                value = [];
            else
                value = horzcat(obj.Epochs.ID);
            end
        end
    end

    methods
        function setHomeDirectory(obj, filePath)
            % SETHOMEDIRECTORY
            %
            % Description:
            %   Set a new base filepath. Useful if you are analyzing data 
            %   on multiple computers
            %
            % Syntax:
            %   setHomeDirectory(obj, filePath)
            % -------------------------------------------------------------
            arguments
                obj
                filePath            {mustBeFolder(filePath)}
            end
            obj.homeDirectory = filePath;
        end
        
        function setDate(obj, expDate)
            % Change the experiment's date
            %
            % Syntax:
            %   setDate(obj, expDate)
            %
            % Inputs:
            %   expDate         datetime or text in format 'YYYYMMdd'
            % -------------------------------------------------------------
            obj.experimentDate = aod.util.validateDate(expDate);
        end
        
        
        function epoch = id2epoch(obj, IDs)
            % ID2EPOCH
            %
            % Description:
            %   Input epoch ID(s), get Epoch(s)
            %
            % Syntax:
            %   epoch = id2epoch(obj, IDs)
            % -------------------------------------------------------------
            if ~isscalar(IDs)
                epoch = aod.util.arrayfun(@(x) obj.Epochs(find(obj.epochIDs==x)), IDs);
            else
                epoch = obj.Epochs(find(obj.epochIDs == IDs));
            end
        end

        function idx = id2index(obj, IDs)
            % ID2INDEX
            %
            % Description:
            %   Returns index of an epoch given an epoch ID
            %
            % Syntax:
            %   idx = id2index(obj, IDs)
            % -------------------------------------------------------------
            if ~isscalar(IDs)
                idx = arrayfun(@(x) id2index(obj, x), IDs);
                return
            end
            idx = find(obj.epochIDs == IDs);
        end
    end 

    methods
        function add(obj, entity)
            % Add a new entity to the Experiment 
            %
            % Description:
            %   Add a new entity or entities to the experiment
            %
            % Syntax:
            %   add(obj, entity)
            %
            % Inputs:
            %   entity          aod.core.Entity
            %       One or more entities of the same entity type
            %
            % Notes: Only entities contained by  experiment can be added:
            %   Analysis, Epoch, Calibration, Annotation, Source, System
            % ------------------------------------------------------------- 
            arguments
                obj
                entity      {mustBeA(entity, 'aod.core.Entity')}
            end

            if ~isscalar(entity)
                for i = 1:numel(entity)
                    obj.add(entity(i));
                end
                return
            end

            import aod.core.EntityTypes
            entityType = EntityTypes.get(entity);

            switch entityType 
                case EntityTypes.ANALYSIS
                    entity.setParent(obj);
                    if isempty(obj.Analyses)
                        obj.Analyses = entity;
                    else
                        obj.Analyses = cat(1, obj.Analyses, entity);
                    end
                case EntityTypes.ANNOTATION
                    entity.setParent(obj);
                    if isempty(obj.Annotations)
                        obj.Annotations = entity;
                    else
                        obj.Annotations = cat(1, obj.Annotations, entity);
                    end
                case EntityTypes.CALIBRATION
                    entity.setParent(obj);
                    if isempty(obj.Calibrations)
                        obj.Calibrations = entity;
                    else
                        obj.Calibrations = cat(1, obj.Calibrations, entity);
                    end
                case EntityTypes.EPOCH
                    obj.addEpoch(entity);
                case EntityTypes.EXPERIMENTDATASET
                    if isempty(obj.ExperimentDatasets)
                        obj.ExperimentDatasets = entity;
                    else
                        obj.ExperimentDatasets = cat(1, obj.ExperimentDatasets, entity);
                    end
                case EntityTypes.SYSTEM 
                    entity.setParent(obj);
                    if isempty(obj.Systems)
                        obj.Systems = entity;
                    else
                        obj.Systems = cat(1, obj.Systems, entity);
                    end
                case EntityTypes.SOURCE 
                    obj.addSource(entity);
                otherwise
                    error("Experiment:AddedInvalidEntity",...
                        "Entity must be Analysis, Calibration, Annotation, Epoch, ExperimentDataset, Source or System");
            end
        end

        function remove(obj, entityType, varargin)
            % Remove specific entites or clear all entities of a given type
            %
            % Syntax:
            %   remove(obj, entityType, idx)
            %
            % Examples:
            %   % Remove the 2nd calibration
            %   remove(obj, 'Calibration', 2);
            %
            %   % Remove all systems
            %   remove(obj, 'System', 'all');
            % -------------------------------------------------------------

            import aod.core.EntityTypes

            % Identify and validate entity type to remove
            entityType = EntityTypes.get(entityType);
            if ~ismember(entityType, obj.entityType.validChildTypes())
                error('remove:NonChildEntityType',...
                    'Entity must be Analysis, Annotation, Calibration, Epoch, ExperimentDataset, Source or System');
            end

            % Identify which members of entityType to remove
            if istext(varargin{1}) && strcmp(varargin{1}, "all")
                % Remove all entities
                obj.(entityType.parentContainer) = entityType.empty();
                return
            elseif isnumeric(varargin{1})
                % Remove entities by ID
                ID = varargin{1};
                % Validate IDs
                mustBeInteger(ID);
                if entityType == EntityTypes.EPOCH
                    mustBeMember(ID, obj.epochIDs);
                else
                    mustBeInRange(ID, 1, numel(obj.(entityType.parentContainer)));
                end
                ID = sort(ID, 'descend');
            elseif iscell(varargin{1})
                % Remove entities matching one or more queries
                out = aod.core.EntitySearch.go(obj.(entityType.parentContainer), varargin{:});
                if isempty(out)
                    warning('remove:NoMatches', 'Query did not return any matches');
                    return
                end
                % Identify IDs corresponding to matched entities
                ID = [];
                for i = 1:numel(out)
                    ID = cat(1, ID, find(obj.(entityType.parentContainer) == out(i)));
                end
            else
                error('remove:InvalidId',...
                    'ID must be "all", an integer indices of entities to remove');
            end

            switch entityType
                case EntityTypes.ANALYSIS
                    removeParent(obj.Analyses(ID));
                    obj.Analyses(ID) = [];
                case EntityTypes.ANNOTATION 
                    removeParent(obj.Annotations(ID));
                    obj.Annotations(ID) = [];
                case EntityTypes.CALIBRATION
                    removeParent(obj.Calibrations(ID));
                    obj.Calibrations(ID) = [];
                case EntityTypes.EPOCH 
                    aod.util.mustBeEpochID(obj, ID);
                    removeParent(obj.Epochs(obj.id2index(ID)));
                    obj.Epochs(obj.id2index(ID)) = [];
                case EntityTypes.EXPERIMENTDATASET
                    removeParent(obj.ExperimentDatasets(ID));
                    obj.ExperimentDatasets(ID) = [];
                case EntityTypes.SOURCE
                    removeParent(obj.Sources(ID));
                    obj.Sources(ID) = [];
                case EntityTypes.SYSTEM
                    removeParent(obj.Systems(ID));
                    obj.Systems(ID) = [];
            end
        end
        
        function tf = has(obj, entityType, varargin)
            % Search Experiment's child entities & return if matches exist
            %
            % Description:
            %   Search all entities of a specific type that match the given
            %   criteria & return if matches exist
            %
            % Syntax:
            %   tf = has(obj, entityType, varargin)
            %
            % Inputs:
            %   entityType          char or aod.core.EntityTypes
            % Optional inputs:
            %   One or more cells containing queries
            %
            % See also:
            %   aod.core.Experiment/get
            % -------------------------------------------------------------
            out = obj.get(entityType, varargin{:});
            tf = ~isempty(out);
        end

        function out = get(obj, entityType, varargin)
            % Search all entities of a specific type within experiment
            %
            % Description:
            %   Search all entities of a specific type that match the given
            %   criteria (described below in examples)
            %
            % Inputs:
            %   entityType          char or aod.core.EntityTypes
            %
            % Examples:
            % Search for Sources named "OD"
            %   out = obj.get('Source', 'Name', "OD")
            %
            % Search for Devices of class "aod.builtin.devices.Pinhole"
            %   out = obj.get('Device', 'Class', 'aod.builtin.devices.Pinhole')
            %
            % Search for Calibrations that are a subclass of 
            % "aod.builtin.calibrations.PowerMeasurement"
            %   out = obj.get('Calibration', 'Subclass',... 
            %       'aod.builtin.calibrations.PowerMeasurement')
            %
            % Search for Epochs that have Parameter "Defocus"
            %   out = obj.get('Epoch', 'Parameter', 'Defocus')
            %
            % Search for Epochs with Parameter "Defocus" = 0.3
            %   out = obj.get('Epoch', 'Parameter', 'Defocus', 0.3)
            % -------------------------------------------------------------

            import aod.core.EntityTypes

            entityType = EntityTypes.get(entityType);

            switch entityType
                case EntityTypes.SOURCE
                    group = obj.getAllSources();
                case EntityTypes.SYSTEM 
                    group = obj.Systems;
                case EntityTypes.CHANNEL                          
                    if isempty(obj.Systems)
                        group = aod.core.Channel.empty();
                    else
                        group = vertcat(obj.Systems.Channels);
                    end
                case EntityTypes.DEVICE            
                    if isempty(obj.Systems)
                        group = aod.core.Device.empty();
                    else
                        group = vertcat(obj.Systems.getChannelDevices());
                    end
                case EntityTypes.CALIBRATION
                    group = obj.Calibrations;
                case EntityTypes.EXPERIMENTDATASET 
                    group = obj.ExperimentDatasets;
                case EntityTypes.EPOCH
                    group = obj.Epochs;
                case EntityTypes.RESPONSE
                    group = obj.getFromEpoch('all', 'Response');
                case EntityTypes.REGISTRATION
                    group = obj.getFromEpoch('all', 'Registration');
                case EntityTypes.EPOCHDATASET 
                    group = obj.getFromEpoch('all', 'EpochDataset');
                case EntityTypes.STIMULUS
                    group = obj.getFromEpoch('all', 'Stimulus');
                case EntityTypes.ANNOTATION
                    group = obj.Annotations;
                case EntityTypes.ANALYSIS
                    group = obj.Analyses;
                case EntityTypes.EXPERIMENT
                    out = obj;  % There is only one experiment
                    return
            end

            if nargin > 2 && ~isempty(group)
                out = aod.core.EntitySearch.go(group, varargin{:});
            else
                out = group;
            end
        end
    end

    % Epoch methods
    methods
        function out = getFromEpoch(obj, ID, entityType, varargin)
            % Get entities from one, multiple or all epochs
            %
            % Syntax:
            %   out = getFromEpoch(obj, ID, entityType, varargin)
            %
            % Inputs:
            %   ID          integer or empty
            %       Epoch ID(s). For all epochs, set to 'all' or []
            %   entityType      aod.core.EntityTypes or char
            %       Entity type to get (epoch dataset, registration,  
            %       stimulus or response)
            % Optional inputs:
            %   varargin    queries, IDs or 'all'
            %
            % Examples:
            %   % Get all epoch datasets for all epochs
            %   out = obj.getFromEpoch('all', 'EpochDataset')
            %
            %   % Get responses from epoch #1
            %   out = obj.getFromEpoch(1, 'Responses')
            %
            %   % Get stimuli from epochs 1:3 matching a query
            %   out = obj.getFromEpoch(1:3, 'Stimulus', {'Name', 'Mustang'})
            % -------------------------------------------------------------
            
            import aod.core.EntityTypes
            
            entityType = EntityTypes.get(entityType);
            if ~ismember(entityType, EntityTypes.EPOCH.validChildTypes())
                error('getFromEpoch:NonChildEntityType',...
                    'Can only access child entities of Epoch');
            end

            if isempty(obj.Epochs)
                out = [];
            end

            if isempty(ID)
                ID = obj.epochIDs;
            elseif istext(ID) && strcmpi(ID, 'all')
                ID = obj.epochIDs;
            else
                aod.util.mustBeEpochID(obj, ID);
            end
            idx = obj.id2index(ID);

            switch entityType 
                case EntityTypes.EPOCHDATASET
                    group = vertcat(obj.Epochs(idx).EpochDatasets);
                case EntityTypes.REGISTRATION
                    group = vertcat(obj.Epochs(idx).Registrations);
                case EntityTypes.RESPONSE
                    group = vertcat(obj.Epochs(idx).Responses);
                case EntityTypes.STIMULUS 
                    group = vertcat(obj.Epochs(idx).Stimuli);
            end
            
            if isempty(group)
                out = group;
                return
            end

            % Default is empty unless meets criteria below
            if nargin > 3
                % Was index provided for entities returned?
                if ~iscell(varargin{1})
                    entityID = varargin{1};
                    if isnumeric(entityID)
                        mustBeInteger(entityID); mustBeInRange(entityID, 1, numel(group));
                        group = group(entityID);
                    end 
                    % Were queries provided as well
                    if nargin > 4
                        out = aod.core.EntitySearch.go(group, varargin{2:end});
                    else
                        out = group;
                    end
                else % Was the extra input just queries
                    if ~isempty(group)
                        out = aod.core.EntitySearch.go(group, varargin{:});
                    end
                end
            else
                out = group;
            end
        end

        function removeByEpoch(obj, ID, entityType, entityID)
            % Remove entities from child Epoch(s)
            %
            % Syntax:
            %   removeByEpoch(obj, ID, entityType, entityID)
            %
            % Inputs:
            %   ID              integer or "all"
            %       Epoch IDs to process
            %   entityType      aod.core.EntityTypes or char
            %       Type of entity within Epoch to remove
            % Optional inputs:
            %   entityID        integer or "all" (default = "all")
            %       Entity indices to process
            %
            % -------------------------------------------------------------

            if nargin < 4
                entityID = "all";
            end

            if istext(ID) && strcmpi(ID, 'all')
                ID = obj.epochIDs;
            else
                aod.util.mustBeEpochID(obj, ID);
            end

            import aod.core.EntityTypes
            entityType = aod.core.EntityTypes.get(entityType);
            if ~ismember(entityType, EntityTypes.EPOCH.validChildTypes())
                error('removeByEpoch:InvalidEntityType',...
                    'Only child entities of Epoch can be removed');
            end

            % Use the remove method defined by Epoch
            for i = 1:numel(ID)
                remove(obj.id2epoch(ID(i)), entityType, entityID);
            end
        end
    end

    methods (Access = protected)
        function addEpoch(obj, epoch)
            % ADDEPOCH
            %
            % Syntax:
            %   obj.addEpoch(obj, epoch)
            % -------------------------------------------------------------
            assert(isa(epoch, 'aod.core.Epoch'), 'Input must be an Epoch');

            if ismember(epoch.ID, obj.epochIDs)
                error("addEpoch:EpochIDAlreadyExists",...
                    "Epoch %u is already present", epoch.ID);
            end

            epoch.setParent(obj);

            obj.Epochs = cat(1, obj.Epochs, epoch);
            obj.sortEpochs();
        end

        function addSource(obj, source)
            % ADDSOURCE
            %
            % Description:
            %   Assign source(s) to the experiment
            %
            % Syntax:
            %   obj.addSource(source, overwrite)
            %
            % Note:
            %   To add a new Source to an existing source, use the 
            %   add function of the target parent aod.core.Source
            % -------------------------------------------------------------
            assert(isSubclass(source, 'aod.core.Source'),...
                'Must be a subclass of aod.core.Source');
            for i = 1:numel(source)
                % Get the full source hierarchy
                h = source.getParents();
                % Set the parent of the top-level source
                if isempty(h)
                    source.setParent(obj);
                    obj.Sources = cat(1, obj.Sources, source);
                else % Source has parents
                    % TODO: Recognize existing parents
                    h(1).setParent(obj);
                    obj.Sources = cat(1, obj.Sources, h(1));
                end
            end
        end

        function sortEpochs(obj)
            % SORTEPOCHS
            %
            % Description:
            %   Sorts epochIDs and epochs by increasing numerical order
            % 
            % Syntax:
            %   obj.sortEpochs();
            % -------------------------------------------------------------
            if obj.numEpochs < 2
                return
            end
            [~, idx] = sort(obj.epochIDs);
            obj.Epochs = obj.Epochs(idx);
        end

        function sources = getAllSources(obj)
            % Returns all sources in an Experiment 
            %
            % Description:
            %   Returns all sources and nested sources in Experiment
            %
            % Syntax:
            %   sources = getAllSources(obj)
            % -------------------------------------------------------------
            sources = aod.core.Source.empty();
            if isempty(obj.Sources)
                return
            end
            sources = obj.Sources.getAllSources();
        end 

        function appendGitHashes(obj)
            % APPENDGITHASHES
            %
            % Description:
            %   Append git hashes
            %
            % Syntax:
            %   appendGitHashes(obj)
            % -------------------------------------------------------------
            RM = aod.infra.RepositoryManager();
            obj.Code = RM.repositoryInfo;
        end
    end

    % Overloaded methods
    methods (Access = protected)
        function value = specifyParameters(obj)
            value = specifyParameters@aod.core.Entity(obj);

            value.add('Administrator', string.empty(), @isstring,... 
                'Person(s) performed the experiment');
            value.add('Laboratory', string.empty(), @isstring,... 
                'Lab where the experiment was performed');
        end
    end
end
