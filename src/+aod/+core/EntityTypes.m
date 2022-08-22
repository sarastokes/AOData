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
        RESPONSE
        TIMING
        STIMULUS 
        REGISTRATION 
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
                case {EntityTypes.REGISTRATION, EntityTypes.STIMULUS, EntityTypes.RESPONSE}
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
                    containers = {'Registrations', 'Stimuli', 'Responses'};
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

        function prop = parameters(obj, entity)
            import aod.core.EntityTypes

            switch obj 
                case EntityTypes.EXPERIMENT 
                    prop = entity.experimentParameters;
                case EntityTypes.SOURCE 
                    prop = entity.sourceParameters;
                case EntityTypes.CALIBRATION 
                    prop = entity.calibrationParameters;
                case EntityTypes.SYSTEM 
                    prop = entity.systemParameters;
                case EntityTypes.CHANNEL 
                    prop = entity.channelParameters;
                case EntityTypes.DEVICE 
                    prop = entity.deviceParameters;
                case EntityTypes.EPOCH 
                    prop = entity.epochParameters;
                case EntityTypes.REGISTRATION 
                    prop = entity.registrationParameters;
                case EntityTypes.STIMULUS 
                    prop = entity.stimParameters;
                case EntityTypes.RESPONSE 
                    prop = entity.responseParameters;
                case EntityTypes.REGION 
                    prop = entity.regionParameters;
                case EntityTypes.ANALYSIS 
                    prop = entity.analysisParameters;
                case EntityTypes.TIMING 
                    prop = [];
            end
        end

        function names = allowableParentTypes(obj)
            % TODO: Decide whether to do this here or within classes
            import aod.core.EntityTypes 

            switch obj 
                case EntityTypes.EXPERIMENT
                    names = [];
                case EntityTypes.EPOCH 
                    names = 'aod.core.Experiment';
            end
        end
    end

    methods (Static)
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
    end
end