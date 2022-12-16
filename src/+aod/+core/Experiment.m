classdef Experiment < aod.core.Entity
% EXPERIMENT
%
% Description:
%   A single experiment
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
%   Epochs                      Container for Epochs
%   Source                      Container experiment's for Sources
%   Annotations               Container for experiment's Annotations
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
%   addAnalysis(obj, entity)
%
%   calibration = getCalibration(obj, className)
%   data = getResponse(obj, epochIDs, className, varargin)
%   imStack = getStacks(obj, epochIDs)
%
%   id = id2epoch(obj, epochID)
%   idx = id2index(obj, epochID)
%   clearEpochDatasets(obj, epochIDs)
%   clearEpochRegistrations(obj, epochIDs)
%   clearEpochResponses(obj, epochIDs)
%   clearEpochStimuli(obj, epochIDs)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        homeDirectory           char
        experimentDate(1,1)     datetime

        Analyses                aod.core.Analysis = aod.core.Analysis.empty()
        Epochs                  aod.core.Epoch
        Sources                 aod.core.Source
        Annotations             aod.core.Annotation
        Calibrations            aod.core.Calibration
        Systems                 aod.core.System

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
        function out = search(obj, entityType, varargin)
            % SEARCH
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
            %   out = obj.search('Source', 'Name', "OD")
            %
            % Search for Devices of class "aod.builtin.devices.Pinhole"
            %   out = obj.search('Device', 'Class', 'aod.builtin.devices.Pinhole')
            %
            % Search for Calibrations that are a subclass of 
            % "aod.builtin.calibrations.PowerMeasurement"
            %   out = obj.search('Calibration', 'Subclass',... 
            %       'aod.builtin.calibrations.PowerMeasurement')
            %
            % Search for Epochs that have Parameter "Defocus"
            %   out = obj.search('Epoch', 'Parameter', 'Defocus')
            %
            % Search for Epochs with Parameter "Defocus" = 0.3
            %   out = obj.search('Epoch', 'Parameter', 'Defocus', 0.3)
            % -------------------------------------------------------------

            import aod.core.EntityTypes

            entityType = EntityTypes.init(entityType);

            switch entityType
                case EntityTypes.SOURCE
                    group = obj.getAllSources();
                case EntityTypes.SYSTEM 
                    group = obj.Systems;
                case EntityTypes.CHANNEL;
                    group = obj.getAllChannels();
                case EntityTypes.Device
                    group = obj.getAllDevices();
                case EntityTypes.CALIBRATION
                    group = obj.Calibrations;
                case EntityTypes.ANNOTATION
                    group = obj.Annotations;
                case EntityTypes.EPOCH
                    group = obj.Epochs;
                case EntityTypes.RESPONSE
                    group = obj.getAllResponses();
                case EntityTypes.REGISTRATION
                    group = obj.getEpochRegistrations();
                case EntityTypes.DATASET 
                    group = obj.getEpochDatasets();
                case EntityTypes.STIMULUS
                    group = obj.getEpochStimuli();
                case EntityTypes.ANALYSIS
                    group = obj.Analyses;
                case EntityTypes.EXPERIMENT
                    % There is only one experiment
                    out = obj;
                    return
            end

            egObj = aod.api.EntityGroupSearch(group, varargin);
            out = egObj.getMatches();
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
                %arrayfun(@(x) add(obj, x), entity);
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
                case EntityTypes.CALIBRATION
                    entity.setParent(obj);
                    if isempty(obj.Calibrations)
                        obj.Calibrations = entity;
                    else
                        obj.Calibrations = cat(1, obj.Calibrations, entity);
                    end
                case EntityTypes.EPOCH
                    obj.addEpoch(entity);
                case EntityTypes.ANNOTATION
                    entity.setParent(obj);
                    if isempty(obj.Annotations)
                        obj.Annotations = entity;
                    else
                        obj.Annotations = cat(1, obj.Annotations, entity);
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
                        "Entity must be Analysis, Calibration, Annotation, Source or System");
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

    % Entity access methods
    methods 
        function cal = getCalibration(obj, className)
            % GETCALIBRATION
            %
            % Syntax:
            %   cal = obj.getCalibration(className)
            % -------------------------------------------------------------
            cal = getByClass(obj.Calibrations, className);
        end

        function annotation = getAnnotation(obj, className)
            % GETANNOTATION
            %
            % Syntax:
            %   annotation = obj.getAnnotation(className)
            % -------------------------------------------------------------
            annotation = getByClass(obj.Annotations, className);
        end

        function data = getResponse(obj, epochIDs, className, varargin)
            % GETRESPONSE
            %
            % Description:
            %   Get a response from specified epoch(s)
            %
            % Syntax:
            %   data = getResponse(obj, epochIDs, className, varargin)
            % -------------------------------------------------------------
            ip = inputParser();
            ip.CaseSensitive = false;
            ip.KeepUnmatched = true;
            addParameter(ip, 'Average', false, @islogical);
            parse(ip, varargin{:});
            avgFlag = ip.Results.Average;

            data = [];
            for i = 1:numel(epochIDs)
                epoch = obj.id2epoch(epochIDs(i));
                resp = epoch.getResponse(className, ip.Unmatched);
                data = cat(3, data, resp.Data);
            end

            if avgFlag && ndims(data) == 3
                data = mean(data, 3);
            end
        end

    end

    % Annotation methods
    methods
        function addAnnotation(obj, annotation)
            % ADDANNOTATION
            %
            % Description:
            %   Add aod.core.Annotation entity to the Experiment
            %
            % Syntax:
            %   addAnnotation(obj, annotation)
            % -------------------------------------------------------------
            assert(isSubclass(annotation, 'aod.core.Annotation'),... 
                'Input must be subclass of aod.core.Annotation');

            annotation.setParent(obj);
            obj.Annotations = cat(1, obj.Annotations, annotation);
        end


        function removeAnnotation(obj, ID)
            % REMOVEANNOTATION
            %
            % Description:
            %   Remove one or more annotations by ID 
            %
            % Syntax:
            %   removeAnnotation(obj, ID)
            % -------------------------------------------------------------
            assert(ID > 0 & ID < numel(obj.Annotations),...
                'ID %u invalid, must be between 1-%u', ID, numel(obj.Annotations));
            obj.Annotations(ID) = [];
        end

        function clearAnnotations(obj)
            % CLEARANNOTATIONS
            %
            % Description:
            %   Clear all annotations in the experiment
            %
            % Syntax:
            %   obj.clearAnnotations()
            % -------------------------------------------------------------
            obj.Annotations = aod.core.Annotation.empty();
        end
    end

    % Source methods
    methods
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

        function removeSource(obj, ID)
            % REMOVESOURCE
            %  
            % Description:
            %   Remove a specific source by index
            %
            % Syntax:
            %   removeSource(obj, ID)
            % -------------------------------------------------------------
            assert(ID > 0 & ID <= numel(obj.Sources),...
                'ID %u is invalid, must be between 1 and %u', ID, numel(obj.Sources));
            obj.Sources(ID) = [];
        end

        function clearSources(obj)
            % CLEARSOURCES
            %
            % Description:
            %   Remove all sources in the experiment
            % 
            % Syntax:
            %   clearSources(obj)
            % -------------------------------------------------------------
            obj.Sources = aod.core.Source.empty();
        end
        
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

    % System methods
    methods 
        function system = getSystem(obj, systemName)
            % GETSYSTEM
            %
            % Description:
            %   Get a specific system by name (searches name then label)
            %
            % Syntax:
            %   system = getSystem(obj, systemName)
            % -------------------------------------------------------------
            arguments
                obj
                systemName      string
            end

            if isempty(obj.Systems)
                system = [];
                return 
            end

            idx = find(matches(names, systemName, "IgnoreCase", true));
            if ~isempty(idx)
                system = obj.Systems(idx);
            end
        end

        function removeSystem(obj, ID)
            % REMOVESYSTEM
            %
            % Description:
            %   Remove a system from the experiment
            %
            % Syntax:
            %   removeSystem(obj, ID)
            % -------------------------------------------------------------
            assert(ID > 0 & ID < numel(obj.Systems),...
                'ID %u invalid, must be between 1-%u', ID, numel(obj.Systems));
            obj.Systems(ID) = [];
        end

        function clearSystems(obj)
            % CLEARSYSTEMS
            %
            % Syntax:
            %   obj.clearSystems()
            % -------------------------------------------------------------
            obj.Systems = aod.core.System.empty();
        end
    end

    % System hierarchy methods
    methods 
        function channels = getAllChannels(obj)
            % GETALLCHANNELS
            %
            % Description:
            %   Returns all channels within the experiment
            %
            % Syntax:
            %   channels = getAllChannels(obj)
            % -------------------------------------------------------------
            if isempty(obj.Systems)
                channels = aod.core.Channel.empty();
            else
                channels = vertcat(obj.Systems.Channels);
            end
        end

        function devices = getAllDevices(obj)
            % GETALLDEVICES
            %
            % Description:
            %   Returns all devices within the experiment
            %
            % Syntax:
            %   devices = getAllDevices(obj)
            % -------------------------------------------------------------
            
            if isempty(obj.Systems)
                devices = aod.core.Device.empty();
            else
                devices = vertcat(obj.Systems.getAllDevices());
            end
        end
    end

    % Epoch methods
    methods
        function removeEpoch(obj, epochID)
            % REMOVEEPOCH
            %
            % Syntax:
            %   removeEpoch(obj, epochID)
            % -------------------------------------------------------------
            arguments
                obj
                epochID     {aod.util.mustBeEpochID(obj, epochID)}
            end
            
            idx = obj.id2index(epochID);
            obj.Epochs(idx) = [];
        end
        
        function clearEpochs(obj)
            % CLEAREPOCHS
            %
            % Syntax:
            %   obj.clearEpochs()
            % -------------------------------------------------------------
            obj.Epochs = aod.core.Epoch.empty();
        end

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
    end

    % Calibration methods
    methods
        function removeCalibration(obj, ID)
            % REMOVECALIBRATIONS
            %
            % Syntax:
            %   obj.removeCalibrations(ID)
            % -------------------------------------------------------------
            assert(ID > 0 & ID <= numel(obj.Calibrations),...
                'ID %u is invalid, must be between 1-%u', ID, numel(obj.Calibrations));
            obj.Calibrations(ID) = [];
        end

        function clearCalibrations(obj)
            % CLEARCALIBRATIONS
            %
            % Syntax:
            %   obj.clearCalibrations()
            % -------------------------------------------------------------
            obj.Calibrations = aod.core.Calibration.empty();
        end
    end

    % Analysis methods
    methods
        function removeAnalysis(obj, ID)
            % REMOVEANALYSIS
            %
            % Description:
            %   Remove a system from the experiment
            %
            % Syntax:
            %   removeAnalysis(obj, ID)
            % -------------------------------------------------------------
            assert(ID > 0 & ID <= numel(obj.Analyses),...
                'ID %u invalid, must be between 1 and %u', ID, numel(obj.Analyses));
            obj.Analyses(ID) = [];
        end

        function clearAnalyses(obj)
            % CLEARANALYSES
            %
            % Description:
            %   Clear all analyses in the experiment
            % 
            % Syntax:
            %   clearAnalyses(obj)
            % -------------------------------------------------------------
            obj.Analyses = aod.core.Analysis.empty();
        end
    end

    % Methods for returning or modifying entities for epoch(s)
    methods
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
            stimuli = vertcat(obj.Epochs(epochIDs).Stimuli);
        end

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
                ep.clearDatasets();
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
                ep.clearResponses();
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
                ep.clearRegistrations();
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
                ep.clearStimuli();
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
