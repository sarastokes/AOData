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
        homeDirectory           char
        experimentDate (1,1)    datetime

        Analyses                aod.core.Analysis       = aod.core.Analysis.empty()
        Epochs                  aod.core.Epoch          = aod.core.Epoch.empty()
        Sources                 aod.core.Source         = aod.core.Source.empty()
        Annotations             aod.core.Annotation     = aod.core.Annotation.empty()
        Calibrations            aod.core.Calibration    = aod.core.Calibration.empty()
        Systems                 aod.core.System         = aod.core.System.empty()

        Code                    
    end

    properties (Dependent)
        epochIDs
        numEpochs
    end
    
    methods 
        function obj = Experiment(name, homeFolder, expDate, varargin)
            obj = obj@aod.core.Entity(name);
            obj.setHomeDirectory(homeFolder);
            obj.experimentDate = datetime(expDate, 'Format', 'yyyyMMdd');

            ip = aod.util.InputParser();
            addParameter(ip, 'Administrator', '', @ischar);
            addParameter(ip, 'Laboratory', '', @ischar);
            parse(ip, varargin{:});
            obj.setParam(ip.Results);

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
    end 

    methods
        function add(obj, entity)
            % ADD 
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
                        "Entity must be Analysis, Calibration, Annotation, Epoch, Source or System");
            end
        end

        function remove(obj, entityType, ID)
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
            entityType = EntityTypes.init(entityType);

            % Check whether to clear all entities
            ID = convertCharsToStrings(ID);
            if isstring(ID) && isequal(ID, "all")
                obj.(entityType.parentContainer) = entityType.empty();
                return
            elseif isnumeric(ID)
                mustBeInteger(ID);
                ID = sort(ID, 'descend');
                if entityType ~= EntityTypes.EPOCH
                    mustBeInRange(ID, 1, numel(obj.(entityType.parentContainer)));
                end
            else
                error('remove:InvalidId',...
                    'ID must be "all" or integer index of entities to remove');
            end

            switch entityType
                case EntityTypes.ANALYSIS
                    obj.Analyses(ID) = [];
                case EntityTypes.ANNOTATION 
                    obj.Annotations(ID) = [];
                case EntityTypes.CALIBRATION
                    obj.Calibrations(ID) = [];
                case EntityTypes.EPOCH 
                    aod.util.mustBeEpochID(obj, ID);
                    obj.Epochs(obj.id2index(ID)) = [];
                case EntityTypes.SOURCE
                    obj.Sources(ID) = [];
                case EntityTypes.SYSTEM
                    obj.Systems(ID) = [];
                otherwise
                    error('remove:NonChildEntityType',...
                        'Entity must be Analysis, Annotation, Calibration, Epoch, Source or System');
            end
        end

        function out = get(obj, entityType, queries)
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

            entityType = EntityTypes.init(entityType);

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
                case EntityTypes.ANNOTATION
                    group = obj.Annotations;
                case EntityTypes.EPOCH
                    group = obj.Epochs;
                case EntityTypes.RESPONSE
                    group = obj.getEpochResponses();
                case EntityTypes.REGISTRATION
                    group = obj.getEpochRegistrations();
                case EntityTypes.DATASET 
                    group = obj.getEpochDatasets();
                case EntityTypes.STIMULUS
                    group = obj.getEpochStimuli();
                case EntityTypes.ANALYSIS
                    group = obj.Analyses;
                case EntityTypes.EXPERIMENT
                    out = obj;  % There is only one experiment
                    return
            end

            if nargin > 2 && ~isempty(group)
                out = aod.core.EntitySearch.go(group, queries);
            else
                out = group;
            end
        end
    end

    methods
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

    % Source methods
    methods
        function sources = getAllSources(obj)
            % GETALLSOURCES
            %
            % Description:
            %   Returns up to three levels of sources in expeirment
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
    end

    % Epoch methods
    methods
        function datasets = getEpochDatasets(obj, IDs)
            % GETEPOCHDATASETS
            %
            % Description:
            %   Return the datasets for specified epoch(s)
            %
            % Syntax:
            %   datasets = getEpochDatasets(obj, epochIDs)
            %
            % Inputs:
            %   epochIDs            double
            %       The IDs for 1 or more epochs (not index in Epochs)
            % -------------------------------------------------------------
            if nargin < 2
                IDs = obj.epochIDs;
            end
            IDs = obj.id2index(IDs);
            datasets = vertcat(obj.Epochs(IDs).Datasets);
        end

        function responses = getEpochResponses(obj, IDs)
            % GETEPOCHRESPONSES
            %
            % Description:
            %   Return the responses for the specified epoch(s)
            %
            % Syntax:
            %   responses = getEpochResponses(obj, IDs)
            %
            % Optional inputs:
            %   epochIDs            doubles
            %       The IDs for target epochs (not index in Epochs) 
            % -------------------------------------------------------------
            if nargin < 2
                IDs = obj.epochIDs;
            end
            IDs = obj.id2index(IDs);
            responses = vertcat(obj.Epochs(IDs).Responses);
        end

        function registrations = getEpochRegistrations(obj, epochIDs)
            % GETEPOCHREGISTRATIONS
            %
            % Description:
            %   Return the registrations for specified epoch(s)
            %
            % Syntax:
            %   datasets = getEpochRegistrations(obj, epochIDs)
            %
            % Inputs:
            %   epochIDs            double
            %       The IDs for 1 or more epochs (not index in Epochs)
            % -------------------------------------------------------------
            arguments
                obj
                epochIDs    {aod.util.mustBeEpochID(obj, epochIDs)} = []
            end

            if isempty(epochIDs)
                registrations = vertcat(obj.Epochs.Registrations);
            else
                epochIdx = obj.id2index(epochIDs);
                registrations = vertcat(obj.Epochs(epochIdx).Registrations);
            end
        end

        function stimuli = getEpochStimuli(obj, epochIDs)
            % GETEPOCHSTIMULI
            %
            % Description:
            %   Return the stimuli for specified epoch(s)
            %
            % Syntax:
            %   stimuli = getEpochStimuli(obj, epochIDs)
            %
            % Inputs:
            %   epochIDs            double
            %       The IDs for 1 or more epochs (not index in Epochs)
            % -------------------------------------------------------------
            arguments
                obj
                epochIDs    {aod.util.mustBeEpochID(obj, epochIDs)} = []
            end

            if isempty(epochIDs)
                stimuli = vertcat(obj.Epochs.Stimuli);
            else
                epochIdx = obj.id2index(epochIDs);
                stimuli = vertcat(obj.Epochs(epochIdx).Stimuli);
            end
        end
    end

    % Methods for returning or modifying entities for epoch(s)
    methods
        function clearEpochDatasets(obj, epochIDs)
            % CLEAREPOCHDATASETS
            %
            % Description:
            %   Clear responses in all or a subset of Epochs
            %
            % Syntax:
            %   clearEpochDatasets(obj)
            %   clearEpochDatasets(obj, epochIDs)
            %
            % Note:
            %   If epochIDs is not provided, will clear all epochIDs
            % -------------------------------------------------------------
            if nargin < 2
                epochIDs = obj.epochIDs;
            end
            for i = 1:numel(epochIDs)
                ep = obj.id2epoch(epochIDs(i));
                ep.remove('Dataset', 'all');
            end
        end

        function clearEpochResponses(obj, epochIDs)
            % CLEAREPOCHRESPONSES
            %
            % Description:
            %   Clear responses in all or a subset of Epochs
            %
            % Syntax:
            %   clearEpochResponses(obj)
            %   clearEpochResponses(obj, epochIDs)
            %
            % Note:
            %   If epochIDs is not provided, will clear all epochIDs
            % -------------------------------------------------------------
            if nargin < 2
                epochIDs = obj.epochIDs;
            end
            for i = 1:numel(epochIDs)
                ep = obj.id2epoch(epochIDs(i));
                ep.remove('Response', 'all');
            end
        end

        function clearEpochRegistrations(obj, epochIDs)
            % CLEAREPOCHREGISTRATIONS
            %
            % Syntax:
            %   clearEpochRegistrations(obj)
            %   clearEpochRegistrations(obj, epochIDs)
            %
            % Note:
            %   If epochIDs is not provided, will clear all epochIDs
            % -------------------------------------------------------------
            if nargin < 2
                epochIDs = obj.epochIDs;
            end

            for i = 1:numel(epochIDs)
                ep = obj.id2epoch(epochIDs(i));
                ep.remove('Registration', 'all');
            end
        end

        function clearEpochStimuli(obj, epochIDs)
            % CLEAREPOCHSTIMULI
            %
            % Description:
            %   Clears stimuli in all or a subset of Epochs
            %
            % Syntax:
            %   clearEpochStimuli(obj)
            %   clearEpochStimuli(obj, epochIDs)
            %
            %
            % Note:
            %   If epochIDs is not provided, will clear all epochIDs
            % -------------------------------------------------------------
            if nargin < 2
                epochIDs = obj.epochIDs;
            end

            for i = 1:numel(epochIDs)
                ep = obj.id2epoch(epochIDs(i));
                ep.remove('Stimuli', 'all');
            end
        end
    end

    methods (Access = protected)
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
end
