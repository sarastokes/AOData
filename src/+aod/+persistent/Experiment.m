classdef Experiment < aod.persistent.Entity & matlab.mixin.Heterogeneous & dynamicprops
% An Experiment in an HDF5 file
%
% Description:
%   Represents a persisted Experiment in an HDF5 file
%
% Parent:
%   aod.persistent.Entity, matlab.mixin.Heterogeneous, dynamicprops
%
% Constructor:
%   obj = aod.persistent.Experiment(hdfFile, pathName, factory)
%
% See also:
%   aod.core.Experiment

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        homeDirectory               char
        experimentDate (1,1)        datetime
        epochIDs (1,:)              double
        Code                        table
    end
    
    properties (SetAccess = private)
        AnalysesContainer         
        EpochsContainer   
        ExperimentDatasetsContainer
        SourcesContainer                 
        AnnotationsContainer                 
        CalibrationsContainer            
        SystemsContainer
    end

    properties (Dependent)
        numEpochs
    end

    methods
        function obj = Experiment(hdfName, pathName, factory)
            obj = obj@aod.persistent.Entity(hdfName, pathName, factory);
        end

        function value = get.numEpochs(obj)
            value = numel(obj.epochIDs);
        end
    end

    % Core methods
    methods (Sealed)
        function out = id2index(obj, ID)
            out = [];
            for i = 1:numel(ID)
                iIdx = find(obj.epochIDs == ID(i));
                if isempty(iIdx)
                    error('id2index:EpochIdNotFOund',...
                    'No epoch was found with ID %u', ID(i));
                end
                out = cat(1, out, iIdx);
            end
        end

        function setHomeDirectory(obj, homeDirectory)
            % SETHOMEDIRECTORY
            %
            % Description:
            %   Change the experiment's home directory
            %
            % Syntax:
            %   setHomeDirectory(obj, homeDirectory)
            % -------------------------------------------------------------
            arguments
                obj
                homeDirectory           string
            end

            evtData = aod.persistent.events.DatasetEvent(...
                'homeDirectory', homeDirectory, obj.homeDirectory);
            notify(obj, 'DatasetChanged', evtData);

            obj.homeDirectory = homeDirectory;
        end
    end

    methods
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
            %   entityType          char or aod.common.EntityTypes
            % Optional inputs:
            %   One or more cells containing queries
            %
            % See also:
            %   aod.persistent.Experiment/get
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
            %   entityType          char or aod.common.EntityTypes
            %
            % Examples:
            % Search for Sources named "OD"
            %   out = obj.get('Source', {'Name', "OD"})
            %
            % Search for Devices of class "aod.builtin.devices.Pinhole"
            %   out = obj.get('Device', {'Class', 'aod.builtin.devices.Pinhole'})
            %
            % Search for Calibrations that are a subclass of
            % "aod.builtin.calibrations.PowerMeasurement"
            %   out = obj.get('Calibration',... 
            %       {'Subclass', 'aod.builtin.calibrations.PowerMeasurement'})
            %
            % Search for Epochs that have Attribute "Defocus"
            %   out = obj.get('Epoch', {'Attribute', 'Defocus'})
            %
            % Search for Epochs with Attribute "Defocus" = 0.3
            %   out = obj.get('Epoch', {'Attribute', 'Defocus', 0.3})
            % -------------------------------------------------------------
        
            import aod.common.EntityTypes 

            entityType = EntityTypes.get(entityType);

            switch entityType 
                case EntityTypes.SOURCE 
                    group = obj.Sources.getChildSources();
                case EntityTypes.CHANNEL 
                    if isempty(obj.Systems)
                        group = aod.persistent.Channel.empty();
                    else
                        group = vertcat(obj.Systems.Channels);
                    end
                case EntityTypes.DEVICE
                    if isempty(obj.Systems)
                        group = aod.persistent.Device.empty();
                    else
                        group = obj.Systems.getChannelDevices();
                    end
                case EntityTypes.EXPERIMENT 
                    out = obj;  % There is only one experiment
                    return 
                case {EntityTypes.RESPONSE, EntityTypes.STIMULUS, EntityTypes.EPOCHDATASET, EntityTypes.REGISTRATION}
                    group = obj.getFromEpoch('all', entityType, varargin{:});
                otherwise             
                    group = obj.(entityType.parentContainer());
            end

            if nargin > 2 && ~isempty(group)
                out = aod.common.EntitySearch.go(group, varargin{:});
            else
                out = group;
            end
        end

        function add(obj, entity)
            % Add a new entity to the Experiment
            %
            % Syntax:
            %   add(obj, entity)
            %
            % Examples:
            %   EXPT = loadExperiment('ToyExperiment.h5')
            %   newAnalysis = aod.core.Analysis("Test");
            %   EXPT.add(newAnalysis);
            % -------------------------------------------------------------
            arguments
                obj
                entity      {mustBeA(entity, 'aod.core.Entity')}
            end

            if ~isscalar(entity)
                arrayfun(@(x) add(obj, x), entity);
                return
            end

            import aod.common.EntityTypes

            entityType = EntityTypes.get(entity);
            if ~ismember(entityType, obj.entityType.validChildTypes())
                error('add:InvalidEntityType',...
                    'Only Analysis, Calibration, Epoch, Annotation, System and Source can be added to Experiment');
            end

            entity.setParent(obj);
            obj.addEntity(entity);
        end
    end

    % Child methods
    methods 
        function out = getFromEpoch(obj, ID, entityType, varargin)
            import aod.common.EntityTypes
            
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
            group = vertcat(obj.Epochs(idx).(entityType.parentContainer()));
            
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
                        out = aod.common.EntitySearch.go(group, varargin{2:end});
                    else
                        out = group;
                    end
                else % Was the extra input just queries
                    if ~isempty(group)
                        out = aod.common.EntitySearch.go(group, varargin{:});
                    end
                end
            else
                out = group;
            end
        end
    end

    methods (Sealed, Access = protected)
        function populate(obj)
            populate@aod.persistent.Entity(obj);
 
            % Datasets
            obj.experimentDate = obj.loadDataset('experimentDate');
            obj.homeDirectory = obj.loadDataset('homeDirectory');
            obj.epochIDs = obj.loadDataset('epochIDs');
            obj.Code = obj.loadDataset('Code');

            % Set user-defined datasets and links
            obj.populateDatasetsAsDynProps();
            obj.populateLinksAsDynProps();
        end

        function populateContainers(obj)
            % Containers
            obj.AnalysesContainer = obj.loadContainer('Analyses');
            obj.AnnotationsContainer = obj.loadContainer('Annotations');
            obj.CalibrationsContainer = obj.loadContainer('Calibrations');
            obj.EpochsContainer = obj.loadContainer('Epochs');
            obj.ExperimentDatasetsContainer = obj.loadContainer('ExperimentDatasets');
            obj.SourcesContainer = obj.loadContainer('Sources');
            obj.SystemsContainer = obj.loadContainer('Systems');
        end
    end

    % Container abstraction methods
    methods (Sealed)
        function out = Analyses(obj, idx)
            if nargin < 2
                idx = 0;
            end
            out = [];
            for i = 1:numel(obj)
                out = cat(1, out, obj(i).AnalysesContainer(idx));
            end
        end

        function out = Calibrations(obj, idx)
            if nargin < 2 
                idx = 0;
            end
            out = [];
            for i = 1:numel(obj)
                out = cat(1, out, obj(i).CalibrationsContainer(idx));
            end
        end

        function out = ExperimentDatasets(obj, idx)
            if nargin < 2
                idx = 0;
            end
            out = [];
            for i = 1:numel(obj)
                out = cat(1, out, obj(i).ExperimentDatasetsContainer(idx));
            end
        
        end

        function out = Epochs(obj, idx)
            if nargin < 2
                idx = 0;
            end
            out = [];
            for i = 1:numel(obj)
                out = cat(1, out, obj(i).EpochsContainer(idx));
            end
        end

        function out = Annotations(obj, idx)
            if nargin < 2
                idx = 0;
            end
            out = [];
            for i = 1:numel(obj)
                out = cat(1, out, obj(i).AnnotationsContainer(idx));
            end
        end

        function out = Sources(obj, idx)
            if nargin < 2
                idx = 0;
            end
            out = [];
            for i = 1:numel(obj)
                out = cat(1, out, obj(i).SourcesContainer(idx));
            end
        end

        function out = Systems(obj, idx)
            if nargin < 2
                idx = 0;
            end
            out = [];
            for i = 1:numel(obj)
                out = cat(1, out, obj(i).SystemsContainer(idx));
            end
        end
    end
end