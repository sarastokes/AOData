classdef Experiment < aod.core.Entity
% EXPERIMENT
%
% Description:
%   Parent class for a single experiment
%
% Constructor:
%   obj = Experiment(expDate, source)
%
% Properties:
%   Epochs                      Container for Epochs
%   Source                      Container experiment's for Sources
%   Segmentations               Container for experiment's Segmentations
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
%   calibration = getCalibration(obj, className)
%   data = getResponse(obj, epochIDs, className, varargin)
%   imStack = getStacks(obj, epochIDs)
%
%   addAnalysis(obj, analysis)
%   addCalibration(obj, calibration)
%   addEpoch(obj, epoch)
%   addSegmentation(obj, segmentation)
%   addSystem(obj, system)
%
%   clearEpochDatasets(obj, epochIDs)
%   clearEpochRegistrations(obj, epochIDs)
%   clearEpochResponses(obj, epochIDs)
%   clearEpochStimuli(obj, epochIDs)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        homeDirectory           char
        experimentDate(1,1)     datetime

        Analyses                aod.core.Analysis
        Epochs                  aod.core.Epoch
        Sources                 aod.core.Source
        Segmentations           aod.core.Segmentation
        Calibrations            aod.core.Calibration
        Systems                 aod.core.System

        Code                    % containers.Map
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
            addParameter(ip, 'System', '', @ischar);
            parse(ip, varargin{:});
            obj.setParam(ip.Results);

            obj.appendGitHashes();
        end

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
            assert(isfolder(filePath), 'filePath is not valid!');
            obj.homeDirectory = filePath;
        end

        function add(obj, entity)
            % ADD 
            %
            % Description:
            %   Add a new entity to the experiment
            %
            % Syntax:
            %   add(obj, entity)
            %
            % Notes: Only entities contained by  experiment can be added:
            %   Analysis, Epoch, Calibration, Segmentation, Source, System
            % ------------------------------------------------------------- 
            import aod.core.EntityTypes
            entityType = EntityTypes.get(entity);

            switch entityType 
                case Entity.ANALYSIS
                    entity.setParent(obj);
                    obj.Analyses = cat(1, obj.Analyses, entity);
                case Entity.CALIBRATION
                    entity.setParent(obj);
                    obj.Calibrations = cat(1, obj.Calibrations, entity);
                case Entity.EPOCH
                    obj.addEpoch(entity);
                case Entity.SEGMENTATION
                    entity.setParent(obj);
                    obj.Segmentations = cat(1, obj.Segmentations, entity);
                case Entity.SYSTEM 
                    entity.setParent(obj);
                    obj.Systems = cat(1, obj.Systems, entity);
                case Entity.SOURCE 
                    obj.addSource(entity);
                otherwise
                    error("Experiment:AddedInvalidEntity",...
                        "Entity must be Analysis, Calibration, Segmentation, Source or System");
            end
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
            try
                RM = aod.infra.RepositoryManager();
                obj.Code = RM.commitIDs();
            catch ME  % Rethrow as warning instead of error
                disp(getReport(ME, 'extended', 'hyperlinks', 'on'));
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
            epoch = obj.Epochs(find(obj.epochIDs == IDs));
        end

        function idx = id2index(obj, IDs)
            % ID2INDEX
            %
            % Description:
            %   Returns index of in Epochs for a given epoch ID
            %
            % Syntax:
            %   idx = id2index(obj, IDs)
            % -------------------------------------------------------------
            idx = find(obj.epochIDs == IDs);
        end
    end

    % Property access methods
    methods 
        function cal = getCalibration(obj, className)
            % GETCALIBRATION
            %
            % Syntax:
            %   cal = obj.getCalibration(className)
            % -------------------------------------------------------------
            cal = getByClass(obj.Calibrations, className);
        end

        function segmentation = getSegmentation(obj, className)
            % GETSEGMENTATION
            %
            % Syntax:
            %   segmentation = obj.getSegmentation(className)
            % -------------------------------------------------------------
            segmentation = getByClass(obj.Segmentations, className);
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

    % Segmentation methods
    methods
        function addSegmentation(obj, segmentation)
            % ADDSEGMENTATION
            %
            % Description:
            %   Add aod.core.Segmentation entity to the Experiment
            %
            % Syntax:
            %   addSegmentation(obj, segmentation)
            % -------------------------------------------------------------
            assert(isSubclass(segmentation, 'aod.core.Segmentation'),... 
                'Input must be subclass of aod.core.Segmentation');

            segmentation.setParent(obj);
            obj.Segmentations = cat(1, obj.Segmentations, segmentation);
        end


        function removeSegmentation(obj, ID)
            % REMOVESEGMENTATION
            %
            % Description:
            %   Remove one or more segmentations by ID 
            %
            % Syntax:
            %   removeSegmentation(obj, ID)
            % -------------------------------------------------------------
            assert(ID > 0 & ID < numel(obj.Segmentations),...
                'ID %u invalid, must be between 1-%u', ID, numel(obj.Segmentations));
            obj.Segmentations(ID) = [];
        end

        function clearSegmentations(obj)
            % CLEARSEGMENTATIONS
            %
            % Description:
            %   Clear all segmentations in the experiment
            %
            % Syntax:
            %   obj.clearSegmentations()
            % -------------------------------------------------------------
            obj.Segmentations = aod.core.Segmentation.empty();
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
            %   addSource function of the target parent aod.core.Source
            % -------------------------------------------------------------
            assert(isSubclass(source, 'aod.core.Source'),...
                'Must be a subclass of aod.core.Source');
            for i = 1:numel(source)
                % Get the full source hierarchy
                h = source.getParents();
                % Set the parent of the top-level source
                if isempty(h)
                    source.setParent(obj);
                else
                    h(1).setParent(obj);
                end
                obj.Sources = cat(1, obj.Sources, source);
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
            assert(ID > 0 & ID < numel(obj.Sources),...
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
            obj.Sources = aod.core.Sources.empty();
        end
        

        function sources = getAllSources(obj)
            % GETALLSOURCES
            %
            % Description:
            %   Returns up to three levels of sources in expeirment
            %
            % Syntax:
            %   sources = getAllSources(obj)
            %
            % TODO: Improve to return more than 3 levels of sources
            % -------------------------------------------------------------
            sources = aod.core.Source.empty();
            if isempty(obj.Sources)
                return
            end
            firstOrderSources = obj.Sources;
        
            for i = 1:numel(firstOrderSources)
                if ~isempty(firstOrderSources(i).Sources)
                    sources = cat(1, sources, firstOrderSources(i).Sources);
                end
            end
        
            for i = 1:numel(sources)
                if ~isempty(sources(i).Sources)
                    sources = cat(1, sources, sources(i).Sources);
                end
            end
            sources = cat(1, sources, firstOrderSources);
        end
    end

    % System methods
    methods 
        function addSystem(obj, system)
            % ADDSYSTEM
            %
            % Description:
            %   Add a System to the expeirment
            %
            % Syntax:
            %   obj.addSystem(system)
            % -------------------------------------------------------------
            assert(isSubclass(system, 'aod.core.System'),...
                'Must be a subclass of aod.core.System');
            for i = 1:numel(system)
                system(i).setParent(obj);
                obj.Systems = cat(1, obj.Systems, system(i));
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
                devices = aod.core.Devices.empty();
            else
                devices = vertcat(obj.Systems.Channels.Devices);
            end
        end
    end

    % Epoch methods
    methods
        function addEpoch(obj, epoch)
            % ADDEPOCH
            %
            % Syntax:
            %   obj.addEpoch(obj, epoch)
            % -------------------------------------------------------------
            assert(isa(epoch, 'aod.core.Epoch'), 'Input must be an Epoch');

            if ismember(epoch.ID, obj.epochIDs)
                error("addEpoch:EpochAlreadyExists",...
                    "Epoch %u is already present", epoch.ID);
            end

            epoch.setParent(obj);

            obj.Epochs = cat(1, obj.Epochs, epoch);
            obj.sortEpochs();
        end
        
        function removeEpochByID(obj, epochID)
            % REMOVEEPOCHS
            %
            % Syntax:
            %   removeEpoch(obj, epochID)
            % -------------------------------------------------------------
            assert(ismember(epochID, obj.epochIDs), 'ID not found in epochIDs!');
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
    end

    % Calibration methods
    methods
        function addCalibration(obj, calibration)
            % ADDCALIBRATION
            %
            % Description:
            %   Add calibration(s) to the experiment
            %
            % Syntax:
            %   obj.addCalibration(obj, calibration)
            %
            % Input:
            %   calibration             aod.core.Calibration subclass
            %       A calibration or array of calibrations
            % -------------------------------------------------------------
            assert(isSubclass(calibration, 'aod.core.Calibration'),...
                'addCalibration: Input must be subclass of aod.core.Calibration');
            
            for i = 1:numel(calibration)
                calibration(i).setParent(obj);
                obj.Calibrations = cat(1, obj.Calibrations, calibration(i));
            end
        end

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
        function addAnalysis(obj, analysis)
            % ADDANALYSIS
            %
            % Description:
            %   Add analysis to experiment
            %
            % Syntax:
            %   addAnalysis(obj, analysis)
            % -------------------------------------------------------------
            assert(isSubclass(analysis, 'aod.core.Analysis'),... 
            'Input must be subclass of aod.core.Analysis');

            analysis.setParent(obj);
            obj.Analyses = cat(1, obj.Analyses, analysis);
        end

        function removeAnalysis(obj, ID)
            % REMOVEANALYSIS
            %
            % Description:
            %   Remove a system from the experiment
            %
            % Syntax:
            %   removeAnalysis(obj, ID)
            % -------------------------------------------------------------
            assert(ID > 0 & ID < numel(obj.Analyses),...
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

    % Control of Epoch properties, use at own risk
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
                ep.clearDatasets();
            end
        end

        function clearEpochResponses(obj, epochIDs)
            % CLEARALLRESPONSES
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
    end
end
