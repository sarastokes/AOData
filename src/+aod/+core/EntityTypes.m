classdef EntityTypes

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
                case EntityTypes.SOURCE
                    parents = {'aod.core.Experiment', 'aod.core.Source'};
                case EntityTypes.CHANNEL 
                    parents = {'aod.core.System'};
                case EntityTypes.DEVICE
                    parents = {'aod.core.Channel'};
                case {EntityTypes.REGISTRATION, EntityTypes.STIMULUS, EntityTypes.RESPONSE, EntityTypes.DATASET}
                    parents = {'aod.core.Epoch'};
                case EntityTypes.TIMING
                    parents = {'aod.core.Response'};
                case {EntityTypes.EPOCH, EntityTypes.SYSTEM, EntityTypes.ANALYSIS, EntityTypes.REGION, EntityTypes.CALIBRATION}
                    parents = {'aod.core.Experiment'};
                case EntityTypes.EXPERIMENT
                    parents = {};
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
                case EntityTypes.RESPONSE
                    containers = {'Timing'};
                otherwise
                    containers = [];
            end
        end
    end

    methods (Static)
        function out = getEntityGroupName(entity)
            import aod.core.EntityTypes

            obj = aod.core.EntityTypes.get(entity);

            switch obj
                case EntityTypes.EXPERIMENT
                    out = 'Experiment';
                case EntityTypes.EPOCH
                    if ~isempty(obj.Name)
                        out = obj.Name;
                    else
                        out = ['Epoch', int2fixedwidthstr(entity.ID, 4)];
                    end
                otherwise
                    if ~isempty(entity.Name)
                        out = entity.Name;
                    else
                        out = entity.label;
                    end
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