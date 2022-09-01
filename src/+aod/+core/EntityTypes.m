classdef EntityTypes
% ENTITYTYPES
%
% Description:
%   Establishes business logic for entities
% -------------------------------------------------------------------------

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
        function parents = parentTypes(obj)
            import aod.core.EntityTypes

            switch obj 
                case EntityTypes.EXPERIMENT
                    parents = {};
                case EntityTypes.SOURCE
                    parents = {'aod.core.Experiment', 'aod.core.Source'};
                case {EntityTypes.EPOCH, EntityTypes.SYSTEM, EntityTypes.ANALYSIS, EntityTypes.REGION, EntityTypes.CALIBRATION}
                    parents = {'aod.core.Experiment'};
                case EntityTypes.CHANNEL 
                    parents = {'aod.core.System'};
                case EntityTypes.DEVICE
                    parents = {'aod.core.Channel'};
                case {EntityTypes.REGISTRATION, EntityTypes.STIMULUS, EntityTypes.RESPONSE, EntityTypes.DATASET}
                    parents = {'aod.core.Epoch'};
                case EntityTypes.TIMING
                    parents = {'aod.core.Epoch', 'aod.core.Response'};
            end
        end

        function value = containerName(obj)
            % CONTAINERNAME
            %
            % Description:
            %   Returns the container name for a given entity
            % 
            % Syntax:
            %   value = containerName(obj)
            % -------------------------------------------------------------
            import aod.core.EntityTypes

            switch obj
                case EntityTypes.ANALYSIS
                    value = 'Analysis';
                case EntityTypes.CALIBRATION
                    value = 'Calibrations';
                case EntityTypes.CHANNEL
                    value = 'Channels';
                case EntityTypes.DATASET
                    value = 'Datasets';
                case EntityTypes.DEVICE
                    value = 'Devices';
                case EntityTypes.EPOCH
                    value = 'Epochs';
                case EntityTypes.REGION
                    value = 'Regions';
                case EntityTypes.REGISTRATION
                    value = 'Registrations';
                case EntityTypes.RESPONSE
                    value = 'Responses';
                case EntityTypes.SOURCE
                    value = 'Sources';
                case EntityTypes.STIMULUS
                    value = 'Stimuli';
                case EntityType.SYSTEM
                    value = 'Systems';
                otherwise
                    value = [];
            end
        end

        function containers = containers(obj)
            % CONTAINERS
            %
            % Description:
            %   Defines and returns the default container classes created 
            %   for specific entities
            % -------------------------------------------------------------
            import aod.core.EntityTypes

            switch obj
                case EntityTypes.EXPERIMENT
                    containers = {'Calibrations', 'Analyses', 'Epochs', 'Systems', 'Regions', 'Sources'};
                case EntityTypes.SOURCE 
                    containers = {'Sources'};
                case EntityTypes.EPOCH
                    containers = {'Registrations', 'Stimuli', 'Responses', 'Datasets'};
                case EntityTypes.SYSTEM 
                    containers = {'Channels'};
                case EntityTypes.CHANNEL 
                    containers = {'Devices'};
                otherwise
                    containers = [];
            end
        end

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

        function obj = factory(entityType)
            entityType = upper(entityType);
            try
                obj = aod.core.EntityTypes.(entityType);
            catch ME 
                if strcmp(ME.id, 'MATLAB:subscripting:classHasNoPropertyOrMethod')
                    error("ENTITYTYPES:UnrecognizedEntity",...
                        "aod.core.EntityTypes has no entity named %s", entityType);
                else
                    rethrow(ME);
                end
            end
        end

        function value = get(obj)

            arguments 
                obj         {mustBeA(obj, 'aod.core.Entity')}
            end

            import aod.core.EntityTypes 

            if isSubclass(obj, 'aod.core.Experiment')
                value = EntityTypes.EXPERIMENT;
            elseif isSubclass(obj, 'aod.core.Source')
                value = EntityTypes.SOURCE;
            elseif isSubclass(obj, 'aod.core.Calibration')
                value = EntityTypes.CALIBRATION;
            elseif isSubclass(obj, 'aod.core.System')
                value = EntityTypes.SYSTEM;
            elseif isSubclass(obj, 'aod.core.Channel')
                value = EntityTypes.CHANNEL;
            elseif isSubclass(obj, 'aod.core.Device')
                value = EntityTypes.DEVICE;
            elseif isSubclass(obj, 'aod.core.Epoch')
                value = EntityTypes.EPOCH;
            elseif isSubclass(obj, 'aod.core.Dataset')
                value = EntityTypes.DATASET;
            elseif isSubclass(obj, 'aod.core.Registration')
                value = EntityTypes.REGISTRATION;
            elseif isSubclass(obj, 'aod.core.Stimulus')
                value = EntityTypes.STIMULUS;
            elseif isSubclass(obj, 'aod.core.Response')
                value = EntityTypes.RESPONSE;
            elseif isSubclass(obj, 'aod.core.Analysis')
                value = EntityTypes.ANALYSIS;
            elseif isSubclass(obj, 'aod.core.Region')
                value = EntityTypes.REGION;
            elseif isSubclass(obj, 'aod.core.Timing')
                value = EntityTypes.TIMING;
            else
                error('Unrecognized entity type: %s', class(obj));
            end
        end

        function obj = init(entityName)
            if isa(entityType, 'aod.util.EntityTypes')
                obj = entityName;
                return
            end

            try
                obj = aod.util.EntityTypes.(upper(entityName));
            catch
                error("init:InvalidEntityName",...
                    "No EntityType found matching %s", entityName);
            end
        end
    end
end