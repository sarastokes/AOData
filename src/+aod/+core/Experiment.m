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
%   Regions                     Container for experiment's Regions
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
%   imStack = getStacks(obj, epochIDs)
%
%   data = getResponse(obj, epochIDs, className, varargin)
%   data = getRegionResponses(obj, epochIDs)
%   clearAllResponses(obj, epochIDs)
%
%   addCalibration(obj, calibration)
%   addEpoch(obj, epoch)
%   addRegion(obj, region)
%   addSystem(obj, system)
%   sortEpochs(obj)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        homeDirectory           char
        experimentDate(1,1)     datetime

        Epochs                  aod.core.Epoch
        Sources                 aod.core.Source
        Regions                 aod.core.Region
        Calibrations            aod.core.Calibration
        Systems                 aod.core.System
    end

    properties (Dependent)
        epochIDs
        numEpochs
    end

    properties (Hidden, Access = protected)
        allowableParentTypes = {'none'};
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

        function region = getRegion(obj, className)
            % GETREGION
            %
            % Syntax:
            %   region = obj.getRegion(className)
            % -------------------------------------------------------------
            region = getByClass(obj.Regions, className);
        end
    
        function addRegion(obj, region)
            % ADDREGIONS
            %
            % Syntax:
            %   imStack = addRegion(obj, region, overwrite)
            % -------------------------------------------------------------
            assert(isa(region, 'aod.core.Region'), 'Input must be Region subclass');
            
            region.setParent(obj);
            obj.Regions = cat(1, obj.Regions, region);
        end

        function removeRegions(obj, ID)
            % REMOVEREGIONS
            %
            % Syntax:
            %   imStack = removeRegions(obj, ID)
            % -------------------------------------------------------------
            if ID > numel(obj.Regions)
                error('removeRegions:InvalidID',... 
                    'Only %u regions present', numel(obj.Regions));
            end
            obj.Regions(ID) = [];
        end

        function clearRegions(obj)
            % CLEARREGIONS
            %
            % Syntax:
            %   obj.clearRegions()
            % -------------------------------------------------------------
            obj.Regions = aod.core.Region.empty();
        end
    end

    methods 
        function imStack = getStacks(obj, epochIDs, varargin)
            % GETSTACKS
            %
            % Syntax:
            %   imStack = getStack(obj, epochIDs, varargin)
            %
            % -------------------------------------------------------------
            ip = inputParser();
            addParameter(ip, 'Average', false, @islogical);
            parse(ip, varargin{:});
            avgFlag = ip.Results.Average;

            imStack = [];
            for i = 1:numel(epochIDs)
                epoch = obj.id2epoch(epochIDs(i));
                imStack = cat(4, imStack, epoch.getStack());
            end

            if avgFlag && ndims(imStack) == 4
                imStack = mean(imStack, 4);
            end
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
            % See also:
            %   aod.core.Source
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
                if ~isempty(obj.Sources)
                    assert(obj.Sources(1).getParentID() == source.getParentID(),...
                        'Experiment may only contain 1 animal');
                end
                obj.Sources = cat(1, obj.Sources, source);
            end
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
            %   Remove a sysetm from the experiment
            %
            % Syntax:
            %   removeSystem(obj, ID)
            % -------------------------------------------------------------
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
            obj.epochIDs = [];
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
                'ID must be between 1-%u, the number of calibrations', numel(obj.Calibrations));
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

    % Control of Epoch properties, use at own risk
    methods
        function clearAllResponses(obj, epochIDs)
            % CLEARALLRESPONSES
            %
            % Description:
            %   Clear responses in all or a subset of Epochs
            %
            % Syntax:
            %   clearAllResponses(obj)
            %   clearAllResponses(obj, epochIDs)
            % -------------------------------------------------------------
            if nargin < 2
                epochIDs = obj.epochIDs;
            end
            for i = 1:numel(epochIDs)
                ep = obj.id2epoch(epochIDs(i));
                ep.clearResponses();
            end
        end

        function clearAllRegistrations(obj)
            % CLEARALLREGISTRATIONS
            %
            % Syntax:
            %   clearAllRegistrations(obj)
            % -------------------------------------------------------------
            for i = 1:numel(obj.Epochs)
                obj.Epochs(i).Registrations = aod.core.Registration.empty();
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
