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
        SEGMENTATION 
        EPOCH 
        DATASET
        STIMULUS 
        REGISTRATION 
        RESPONSE
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
                    parentTypes = {'aod.core.Experiment', 'aod.core.Source', 'aod.core.persistent.Experiment', 'aod.core.persistent.Source'};
                case {EntityTypes.EPOCH, EntityTypes.SYSTEM, EntityTypes.ANALYSIS, EntityTypes.SEGMENTATION, EntityTypes.CALIBRATION}
                    parentTypes = {'aod.core.Experiment', 'aod.core.persistent.Experiment'};
                case EntityTypes.CHANNEL 
                    parentTypes = {'aod.core.System', 'aod.core.persistent.System'};
                case EntityTypes.DEVICE
                    parentTypes = {'aod.core.Channel', 'aod.core.persistent.Channel'};
                case {EntityTypes.REGISTRATION, EntityTypes.STIMULUS, EntityTypes.RESPONSE, EntityTypes.DATASET}
                    parentTypes = {'aod.core.Epoch', 'aod.core.persistent.Epoch'};
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
                case EntityTypes.SEGMENTATION
                    out = 'Segmentations';
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

        function out = persistentParentContainer(obj)
            out = obj.parentContainer();
            if ~isempty(out)
                out = [out, 'Container'];
            end
        end

        function out = childContainers(obj, fullVariableName)
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
            arguments
                obj
                fullVariableName        logical = false
            end

            import aod.core.EntityTypes

            switch obj
                case EntityTypes.EXPERIMENT
                    out = {'Calibrations', 'Analyses', 'Epochs', 'Systems', 'Segmentations', 'Sources'};
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

            if fullVariableName && ~isempty(out)
                for i = 1:numel(out)
                    out{i} = [out{i}, 'Container'];
                end
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
                case EntityTypes.SEGMENTATION 
                    out = expt.Segmentations;
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

        function out = getCoreClassName(obj)
            % GETCORECLASSNAME
            %
            % Description:
            %   Returns the core class name of entityType (aod.core.X)
            %
            % Syntax:
            %   out = getCoreClassName(obj)
            % -------------------------------------------------------------
            out = ['aod.core.', appbox.capitalize(char(obj))];
        end

        function out = getPersistentClassName(obj)
            % GETPERSISTENTCLASSNAME
            %
            % Description:
            %   Returns the core class name of entityType (aod.core.X)
            %
            % Syntax:
            %   out = getCoreClassName(obj)
            % -------------------------------------------------------------
            out = ['aod.core.persistent.', appbox.capitalize(char(obj))];
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
                case EntityTypes.SEGMENTATION
                    hdfPath = [parentPath, '/Segmentations/', groupName];
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
                case {EntityTypes.SYSTEM, EntityTypes.EPOCH, EntityTypes.SEGMENTATION,...
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

            if ~isa(entity, 'aod.core.EntityTypes')
                obj = aod.core.EntityTypes.get(entity);
            end

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

        function out = allContainerNames(obj)
            % GETALLCONTAINERS
            %
            %
            % Syntax:
            %   out = getAllContainers(obj)
            %
            % -------------------------------------------------------------
            out = ["Sources", "Calibrations", "Segmentations",... 
                "Datasets", "Epochs", "Registrations", "Stimuli",... 
                "Systems", "Channels", "Devices", "Responses", "Analyses"];
        end

        function out = get(obj)
            % GET
            %
            % Description:
            %   Returns the entity type of any subclass of aod.core.Entity
            %   or aod.core.persistent.Entity
            %
            % Syntax:
            %   out = get(obj)
            % -------------------------------------------------------------
            arguments 
                obj         {mustBeA(obj, 'aod.core.Entity')}
            end

            import aod.core.EntityTypes 

            if isSubclass(obj, {'aod.core.Experiment', 'aod.core.persistent.Experiment'})
                out = EntityTypes.EXPERIMENT;
            elseif isSubclass(obj, {'aod.core.Source', 'aod.core.persistent.Source'})
                out = EntityTypes.SOURCE;
            elseif isSubclass(obj, {'aod.core.Calibration', 'aod.core.persistent.Calibration'})
                out = EntityTypes.CALIBRATION;
            elseif isSubclass(obj, {'aod.core.System', 'aod.core.persistent.System'})
                out = EntityTypes.SYSTEM;
            elseif isSubclass(obj, {'aod.core.Channel', 'aod.core.persistent.Channel'})
                out = EntityTypes.CHANNEL;
            elseif isSubclass(obj, {'aod.core.Device', 'aod.core.persistent.Device'})
                out = EntityTypes.DEVICE;
            elseif isSubclass(obj, {'aod.core.Epoch', 'aod.core.persistent.Epoch'})
                out = EntityTypes.EPOCH;
            elseif isSubclass(obj, {'aod.core.Dataset', 'aod.core.persistent.Dataset'})
                out = EntityTypes.DATASET;
            elseif isSubclass(obj, {'aod.core.Registration', 'aod.core.persistent.Registration'})
                out = EntityTypes.REGISTRATION;
            elseif isSubclass(obj, {'aod.core.Stimulus', 'aod.core.persistent.Stimulus'})
                out = EntityTypes.STIMULUS;
            elseif isSubclass(obj, {'aod.core.Response', 'aod.core.persistent.Response'})
                out = EntityTypes.RESPONSE;
            elseif isSubclass(obj, {'aod.core.Analysis', 'aod.core.persistent.Analysis'})
                out = EntityTypes.ANALYSIS;
            elseif isSubclass(obj, {'aod.core.Segmentation', 'aod.core.persistent.Segmentation'})
                out = EntityTypes.SEGMENTATION;
            else
                error('Unrecognized entity type: %s', class(obj));
            end
        end

        function obj = init(entityName)
            % INIT
            %
            % Description:
            %   Initialize from entity name as text
            %
            % Syntax:
            %   obj = aod.core.EntityTypes.init(entityName)
            %
            % Notes:
            %   For compatibility, if a aod.core.EntityTypes is passed as
            %   input, it will be returned without error
            % -------------------------------------------------------------
            if isa(entityName, 'aod.core.EntityTypes')
                obj = entityName;
                return
            end
            
            import aod.core.EntityTypes;

            switch lower(entityName)
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
                case {'segmentation', 'seg'}
                    obj = EntityTypes.SEGMENTATION;
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
                otherwise
                    obj = [];
            end
        end

        function obj = fromClassName(obj, className)
            if isstring(className)
                className = char(className);
            end
            if ~ischar(className)
                className = class(className);
            end

            if ~isSubclass(className, {'aod.core.Entity', 'aod.core.Experiment'})
                error("EntityTypes/fromClassName",...
                    "%s is not an subclass of aod.core.Entity or aod.core.persistent.Entity");
            end
            
            if isSubclass(x, 'aod.core.persistent.Entity')
                obj = x.entityType;
                return
            end

            import aod.core.EntityTypes;
            if isSubclass(x, 'aod.core.Entity')
                if isSubclass(x, 'aod.core.Experiment')
                    obj = EntityTypes.EXPERIMENT;
                elseif isSubclass(x, 'aod.core.Epoch')
                    obj = EntityTypes.EPOCH;
                elseif isSubclass(x, 'aod.core.Source')
                    obj = EntityTypes.SOURCE;
                elseif isSubclass(x, 'aod.core.Calibration')
                    obj = EntityTypes.CALIBRATION;
                elseif isSubclass(x, 'aod.core.Segmentation')
                    obj = EntityTypes.SEGMENTATION;
                elseif isSubclass(x, 'aod.core.System')
                    obj = EntityTypes.SYSTEM;
                elseif isSubclass(x, 'aod.core.Channel')
                    obj = EntityTypes.CHANNEL;
                elseif isSubclass(x, 'aod.core.Device')
                    obj = EntityTypes.DEVICE;
                elseif isSubclass(x, 'aod.core.Analysis')
                    obj = EntityTypes.ANALYSIS;
                elseif isSubclass(x, 'aod.core.Registration')
                    obj = EntityTypes.REGISTRATION;
                elseif isSubclass(x, 'aod.core.Stimulus')
                    obj = EntityTypes.STIMULUS;
                elseif isSubclass(x, 'aod.core.Dataset')
                    obj = EntityTypes.DATASET;
                elseif isSubclass(x, 'aod.core.Response')
                    obj = EntityTypes.RESPONSE;
                end
            end
        end
    end
end