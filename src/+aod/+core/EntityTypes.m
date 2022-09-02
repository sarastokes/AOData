classdef EntityTypes
% ENTITYTYPES
%
% Description:
%   Establishes business logic for entities and their organization within
%   the AOData object model
%
% Methods:
%   parentTypes = validParentTypes(obj)
%       Defines acceptable entity types for setParent()
%   out = parentContainer(obj)
%       Defines the name of the container each entity type is placed in
%   out = childContainers(obj)
%       Defines the child containers within each entity type
%   
%   out = collectAll(obj, experiment)
%       Returns all members of an entity type within an experiment
%   out = empty(obj)
%       Returns an empty instance of the entity type class
%   
%   obj = init(entityName)
%       Returns the entity type given the entity name
%   obj = get(entity)
%       Given an entity (aod.core.Entity subclass), returns the entity type
% -------------------------------------------------------------------------

    % Core entities in the order they are written to HDF5 files
    enumeration
        EXPERIMENT
        SOURCE 
        CALIBRATION
        SYSTEM
        CHANNEL 
        DEVICE 
        REGION 
        EPOCH 
        DATASET
        STIMULUS 
        REGISTRATION 
        RESPONSE
        TIMING
        ANALYSIS 
    end

    methods
        function parentTypes = validParentTypes(obj)
            % VALIDPARENTTYPES
            %
            % Description:
            %   Returns the entity types that can be set to "Parent"
            %
            % Syntax:
            %   parentTypes = validParentTypes(obj)
            % -------------------------------------------------------------
            import aod.core.EntityTypes

            switch obj 
                case EntityTypes.EXPERIMENT
                    parentTypes = {'none'};
                case EntityTypes.SOURCE
                    parentTypes = {'aod.core.Experiment', 'aod.core.Source'};
                case {EntityTypes.EPOCH, EntityTypes.SYSTEM, EntityTypes.ANALYSIS, EntityTypes.REGION, EntityTypes.CALIBRATION}
                    parentTypes = {'aod.core.Experiment'};
                case EntityTypes.CHANNEL 
                    parentTypes = {'aod.core.System'};
                case EntityTypes.DEVICE
                    parentTypes = {'aod.core.Channel'};
                case {EntityTypes.REGISTRATION, EntityTypes.STIMULUS, EntityTypes.RESPONSE, EntityTypes.DATASET}
                    parentTypes = {'aod.core.Epoch'};
                case EntityTypes.TIMING
                    parentTypes = {'aod.core.Epoch', 'aod.core.Response'};
            end
        end

        function out = parentContainer(obj)
            % PARENTCONTAINER
            %
            % Description:
            %   Returns the name of the container for an entity type
            % 
            % Syntax:
            %   out = parentContainer(obj)
            %
            % Example:
            %   For SYSTEM, parentContainer returns 'Systems'
            % -------------------------------------------------------------
            import aod.core.EntityTypes

            switch obj
                case EntityTypes.ANALYSIS
                    out = 'Analyses';
                case EntityTypes.CALIBRATION
                    out = 'Calibrations';
                case EntityTypes.CHANNEL
                    out = 'Channels';
                case EntityTypes.DATASET
                    out = 'Datasets';
                case EntityTypes.DEVICE
                    out = 'Devices';
                case EntityTypes.EPOCH
                    out = 'Epochs';
                case EntityTypes.REGION
                    out = 'Regions';
                case EntityTypes.REGISTRATION
                    out = 'Registrations';
                case EntityTypes.RESPONSE
                    out = 'Responses';
                case EntityTypes.SOURCE
                    out = 'Sources';
                case EntityTypes.STIMULUS
                    out = 'Stimuli';
                case EntityTypes.SYSTEM
                    out = 'Systems';
                otherwise
                    out = [];
            end
        end

        function out = childContainers(obj)
            % CONTAINERS
            %
            % Description:
            %   Defines and returns the containers within an entity
            %
            % Syntax:
            %   containers = childContainers(obj)
            %
            % Example:
            %   For SYSTEM, childContainers returns 'Channels'
            % -------------------------------------------------------------
            import aod.core.EntityTypes

            switch obj
                case EntityTypes.EXPERIMENT
                    out = {'Calibrations', 'Analyses', 'Epochs', 'Systems', 'Regions', 'Sources'};
                case EntityTypes.SOURCE 
                    out = {'Sources'};
                case EntityTypes.EPOCH
                    out = {'Registrations', 'Stimuli', 'Responses', 'Datasets'};
                case EntityTypes.SYSTEM 
                    out = {'Channels'};
                case EntityTypes.CHANNEL 
                    out = {'Devices'};
                otherwise
                    out = [];
            end
        end
    end

    % Object methods
    methods
        function out = collectAll(obj, expt)
            % COLLECTALL
            %
            % Description:
            %   Returns all members of an entity type within an experiment
            %
            % Syntax:
            %   out = collectAll(obj, experiment)
            % -------------------------------------------------------------
            assert(isSubclass(expt, 'aod.core.Experiment'),...
                'Must provide a subclass of aod.core.Experiment');

            import aod.core.EntityTypes

            out = obj.empty();

            switch obj 
                case EntityTypes.EXPERIMENT
                    out = expt; 
                case EntityTypes.ANALYSIS 
                    out = expt.Analyses;
                case EntityTypes.EPOCH 
                    out = expt.Epochs;
                case EntityTypes.SYSTEM 
                    out = expt.Systems;
                case EntityTypes.REGION 
                    out = expt.Regions;
                case EntityTypes.CHANNEL 
                    out = expt.getAllChannels();
                case EntityTypes.DEVICE 
                    out = expt.getAllDevices();
                case EntityTypes.SOURCE 
                    out = expt.getAllSources();
                case EntityTypes.REGISTRATION
                    if ~isempty(expt.Epochs)
                        out = vertcat(expt.Epochs.Registrations);
                    end
                case EntityTypes.RESPONSE
                    if ~isempty(expt.Epochs)
                        out = vertcat(expt.Epochs.Registrations);
                    end
                case EntityTypes.DATASET 
                    if ~isempty(expt.Epochs)
                        out = vertcat(expt.Epochs.Datasets);
                    end
                case EntityTypes.STIMULUS
                    if ~isempty(expt.Epochs)
                        out = vertcat(expt.Epochs.Stimulus);
                    end
            end
        end 

        function out = empty(obj)
            % EMPTY
            %
            % Description:
            %   Returns an empty instance of the entity type
            %
            % Syntax:
            %   out = empty(obj)
            % -------------------------------------------------------------
            import aod.core.EntityTypes

            switch obj 
                case EntityTypes.EXPERIMENT
                    out = [];
                case EntityTypes.ANALYSIS
                    out = aod.core.Analysis.empty();
                case EntityTypes.CALIBRATION
                    out = aod.core.Calibration.empty();
                case EntityTypes.SYSTEM
                    out = aod.core.System.empty();
                case EntityTypes.CHANNEL
                    out = aod.core.Channel.empty();
                case EntityTypes.DEVICE
                    out = aod.core.Device.empty();
                case EntityTypes.EPOCH
                    out = aod.core.Epoch.empty();
                case EntityTypes.DATASET
                    out = aod.core.Dataset.empty();
                case EntityTypes.REGISTRATION
                    out = aod.core.Registration.empty();
                case EntityTypes.RESPONSE
                    out = aod.core.Response.empty();
                case EntityTypes.STIMULUS
                    out = aod.core.Stimulus.empty();
                otherwise
                    out = [];
            end
        end
    end

    % HDF5 methods
    methods 
        function hdfPath = getPath(obj, entity, manager, parentPath)
            % GETPATH
            %
            % Description:
            %   Determines entity's HDF5 path
            %
            % Syntax:
            %   hdfPath = getPath(obj, entity, manager, parentPath)
            % -------------------------------------------------------------
            assert(isSubclass(entity, 'aod.core.Entity'),...
                'entity must be a subclass of aod.core.Entity');
            assert(isSubclass(manager, 'aod.h5.EntityManager'),...
                'manager must be a subclass of aod.h5.EntityManager');

            if nargin < 4
                parentPath = obj.parentPath(entity, manager);
            end
            groupName = obj.getGroupName(entity);

            import aod.core.EntityTypes

            switch obj 
                case EntityTypes.EXPERIMENT
                    hdfPath = '/Experiment';
                case EntityTypes.SOURCE
                    hdfPath = [parentPath, '/Sources/', groupName];
                case EntityTypes.SYSTEM
                    hdfPath = [parentPath, '/Systems/', groupName];
                case EntityTypes.CHANNEL
                    hdfPath = [parentPath, '/Channels/', groupName];
                case EntityTypes.DEVICE
                    hdfPath = [parentPath, '/Devices/', groupName];
                case EntityTypes.CALIBRATION
                    hdfPath = [parentPath, '/Calibrations/', groupName];
                case EntityTypes.REGION
                    hdfPath = [parentPath, '/Regions/', groupName];
                case EntityTypes.EPOCH
                    hdfPath = [parentPath, '/Epochs/', groupName];
                case EntityTypes.DATASET
                    hdfPath = [parentPath, '/Datasets/', groupName];
                case EntityTypes.REGISTRATION
                    hdfPath = [parentPath, '/Registrations/', groupName];
                case EntityTypes.STIMULUS
                    hdfPath = [parentPath, '/Stimuli/', groupName];
                case EntityTypes.RESPONSE
                    hdfPath = [parentPath, '/Responses/', groupName];
                case EntityTypes.TIMING
                    hdfPath = [parentPath, '/Timing/'];
                case EntityTypes.ANALYSIS
                    hdfPath = [parentPath, '/Analyses/', groupName];
            end
        end

        function hdfPath = parentPath(obj, entity, manager)
            % PARENTPATH
            %
            % Syntax:
            %   hdfPath = parentPath(obj, entity, manager)
            % -------------------------------------------------------------
            assert(isSubclass(entity, 'aod.core.Entity'),...
                'entity must be a subclass of aod.core.Entity');
            assert(isSubclass(manager, 'aod.h5.EntityManager'),...
                'manager must be a subclass of aod.h5.EntityManager');

            import aod.core.EntityTypes

            switch obj 
                case EntityTypes.EXPERIMENT 
                    hdfPath = [];
                case {EntityTypes.SYSTEM, EntityTypes.EPOCH, EntityTypes.REGION,...
                        EntityTypes.ANALYSIS, EntityTypes.CALIBRATION}
                    hdfPath = '/Experiment';
                case EntityTypes.SOURCE 
                    if isempty(entity.Parent)
                        hdfPath = '/Experiment';
                    else
                        hdfPath = manager.uuid2path(entity.Parent.UUID);
                    end
                otherwise
                    hdfPath = manager.uuid2path(entity.Parent.UUID);
            end
        end
    end

    methods (Static)
        function out = getGroupName(entity)
            % GETGROUPNAME
            %
            % Description:
            %   Determines the name of an entity's HDF group
            %
            % Syntax:
            %   out = getGroupName(entity)
            % -------------------------------------------------------------
            import aod.core.EntityTypes

            obj = aod.core.EntityTypes.get(entity);

            switch obj
                case EntityTypes.EXPERIMENT
                    out = 'Experiment';
                case EntityTypes.EPOCH
                    if ~isempty(entity.Name)
                        out = entity.Name;
                    else
                        out = int2fixedwidthstr(entity.ID, 4);
                    end
                otherwise
                    % Default label is Name, if set, className if not
                    out = entity.label;
            end
        end

        function out = get(obj)
            % GET
            %
            % Description:
            %   Returns the entity type of any aod.core.Entity subclass
            %
            % Syntax:
            %   out = get(obj)
            % -------------------------------------------------------------
            arguments 
                obj         {mustBeA(obj, 'aod.core.Entity')}
            end

            import aod.core.EntityTypes 

            if isSubclass(obj, 'aod.core.Experiment')
                out = EntityTypes.EXPERIMENT;
            elseif isSubclass(obj, 'aod.core.Source')
                out = EntityTypes.SOURCE;
            elseif isSubclass(obj, 'aod.core.Calibration')
                out = EntityTypes.CALIBRATION;
            elseif isSubclass(obj, 'aod.core.System')
                out = EntityTypes.SYSTEM;
            elseif isSubclass(obj, 'aod.core.Channel')
                out = EntityTypes.CHANNEL;
            elseif isSubclass(obj, 'aod.core.Device')
                out = EntityTypes.DEVICE;
            elseif isSubclass(obj, 'aod.core.Epoch')
                out = EntityTypes.EPOCH;
            elseif isSubclass(obj, 'aod.core.Dataset')
                out = EntityTypes.DATASET;
            elseif isSubclass(obj, 'aod.core.Registration')
                out = EntityTypes.REGISTRATION;
            elseif isSubclass(obj, 'aod.core.Stimulus')
                out = EntityTypes.STIMULUS;
            elseif isSubclass(obj, 'aod.core.Response')
                out = EntityTypes.RESPONSE;
            elseif isSubclass(obj, 'aod.core.Analysis')
                out = EntityTypes.ANALYSIS;
            elseif isSubclass(obj, 'aod.core.Region')
                out = EntityTypes.REGION;
            elseif isSubclass(obj, 'aod.core.Timing')
                out = EntityTypes.TIMING;
            else
                error('Unrecognized entity type: %s', class(obj));
            end
        end

        function obj = init(entityName)
            if isa(entityName, 'aod.core.EntityTypes')
                obj = entityName;
                return
            end
            
            import aod.core.EntityTypes;

            entityName = lower(entityName);
            switch entityName
                case {'experiment', 'exp'}
                    obj = EntityTypes.EXPERIMENT;
                case {'source', 'sources', 'src'}
                    obj = EntityTypes.SOURCE;
                case {'system', 'systems', 'sys'}
                    obj = EntityTypes.SYSTEM;
                case {'channel', 'channels', 'cnl', 'chan', 'ch'}
                    obj = EntityTypes.CHANNEL;
                case {'device', 'devices', 'dev'}
                    obj = EntityTypes.DEVICE;
                case {'calibration', 'calibrations', 'cal'}
                    obj = EntityTypes.CALIBRATION;
                case {'epoch', 'epochs','ep'}
                    obj = EntityTypes.EPOCH;
                case {'dataset', 'datasets', 'dset'}
                    obj = EntityTypes.DATASET;
                case {'registration', 'registrations', 'reg'}
                    obj = EntityTypes.REGISTRATION;
                case {'response', 'responses', 'resp'}
                    obj = EntityTypes.RESPONSES;
                case {'stimulus', 'stimuli', 'stim'}
                    obj = EntityTypes.STIMULUS;
                case {'analysis', 'analyses'}
                    obj = EntityTypes.ANALYSIS;
                case {'timing', 'time'}
                    obj = EntityTypes.TIMING;
            end
        end
    end
end