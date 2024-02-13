classdef EntityTypes
% Defines the entity types in the AOData Object Model
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
%   out = persistentParentContainer(obj)
%       Defines the back-end persistent container name
%   out = childContainers(obj, fullVariableName)
%       Defines the child containers within each entity type
%
%   out = collectAll(obj, experiment)
%       Returns all members of an entity type within an experiment
%   out = empty(obj)
%       Returns an empty instance of the entity type class
%
%   out = getCoreClassName(obj)
%       Returns the parent core class (e.g. aod.core.Epoch for EPOCH)
%   out = getPersistentClassName(obj)
%       Returns the parent persistent class (e.g. aod.persistent.Epoch)
%
%   obj = init(entityName)
%       Returns the entity type given the entity name
%   obj = get(entity)
%       Given an entity (aod.core.Entity subclass), returns the entity type

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    % Core entities in the order they are written to HDF5 files
    enumeration
        EXPERIMENT
        SOURCE
        CALIBRATION
        SYSTEM
        CHANNEL
        DEVICE
        ANNOTATION
        EXPERIMENTDATASET
        EPOCH
        EPOCHDATASET
        STIMULUS
        REGISTRATION
        RESPONSE
        ANALYSIS
    end

    methods
        function parentTypes = validParentTypes(obj)
            % Return valid parent entity types
            %
            % Description:
            %   Returns the entity types that can be set to "Parent". This
            %   enforces the AOData Object Model hierarchy
            %
            % Syntax:
            %   parentTypes = validParentTypes(obj)
            % -------------------------------------------------------------

            import aod.common.EntityTypes

            switch obj
                case EntityTypes.EXPERIMENT
                    parentTypes = [];
                case EntityTypes.SOURCE
                    parentTypes = [EntityTypes.EXPERIMENT, EntityTypes.SOURCE];
                case {EntityTypes.EPOCH, EntityTypes.SYSTEM, EntityTypes.ANALYSIS,...
                        EntityTypes.ANNOTATION, EntityTypes.CALIBRATION,...
                        EntityTypes.EXPERIMENTDATASET}
                    parentTypes = EntityTypes.EXPERIMENT;
                case EntityTypes.CHANNEL
                    parentTypes = EntityTypes.SYSTEM;
                case EntityTypes.DEVICE
                    parentTypes = EntityTypes.CHANNEL;
                case {EntityTypes.REGISTRATION, EntityTypes.STIMULUS, EntityTypes.RESPONSE, EntityTypes.EPOCHDATASET}
                    parentTypes = EntityTypes.EPOCH;
            end
        end

        function childTypes = validChildTypes(obj)
            % Return valid child entity types
            %
            % Description:
            %   Implements AOData object model hierarchy with limitations
            %   on which entities can be added to an entity
            %
            % Syntax:
            %   childTypes = validChildTypes(obj)
            % -------------------------------------------------------------

            import aod.common.EntityTypes

            switch obj
                case EntityTypes.EXPERIMENT
                    childTypes = [EntityTypes.ANALYSIS, EntityTypes.ANNOTATION,...
                        EntityTypes.CALIBRATION, EntityTypes.EPOCH, ...
                        EntityTypes.SOURCE, EntityTypes.SYSTEM,...
                        EntityTypes.EXPERIMENTDATASET];
                case EntityTypes.EPOCH
                    childTypes = [EntityTypes.EPOCHDATASET, EntityTypes.REGISTRATION,...
                        EntityTypes.RESPONSE, EntityTypes.STIMULUS];
                case EntityTypes.SYSTEM
                    childTypes = EntityTypes.CHANNEL;
                case EntityTypes.CHANNEL
                    childTypes = EntityTypes.DEVICE;
                case EntityTypes.SOURCE
                    childTypes = EntityTypes.SOURCE;
                otherwise
                    childTypes = [];
            end
        end

        function out = parentContainer(obj, entity)
            % Returns the container name for an entity type
            %
            % Syntax:
            %   out = parentContainer(obj)
            %
            % Example:
            %   For SYSTEM, parentContainer returns 'Systems'
            % -------------------------------------------------------------

            if nargin > 1 && isSubclass(entity, 'aod.persistent.Entity')
                out = obj.persistentParentContainer();
                return
            end

            import aod.common.EntityTypes

            switch obj
                case EntityTypes.SOURCE
                    out = 'Sources';
                case EntityTypes.SYSTEM
                    out = 'Systems';
                case EntityTypes.CHANNEL
                    out = 'Channels';
                case EntityTypes.DEVICE
                    out = 'Devices';
                case EntityTypes.CALIBRATION
                    out = 'Calibrations';
                case EntityTypes.EXPERIMENTDATASET
                    out = 'ExperimentDatasets';
                case EntityTypes.EPOCH
                    out = 'Epochs';
                case EntityTypes.EPOCHDATASET
                    out = 'EpochDatasets';
                case EntityTypes.REGISTRATION
                    out = 'Registrations';
                case EntityTypes.RESPONSE
                    out = 'Responses';
                case EntityTypes.STIMULUS
                    out = 'Stimuli';
                case EntityTypes.ANNOTATION
                    out = 'Annotations';
                case EntityTypes.ANALYSIS
                    out = 'Analyses';
                otherwise
                    out = [];
            end
        end

        function out = persistentParentContainer(obj)
            % Defines the back-end container name for persistent entity
            %
            % Syntax:
            %   out = persistentParentContainer(obj)
            % -------------------------------------------------------------
            out = obj.parentContainer();
            if ~isempty(out)
                out = [out, 'Container'];
            end
        end

        function out = childContainers(obj, fullVariableName)
            % Defines and returns the containers within an entity
            %
            % Syntax:
            %   containers = childContainers(obj, fullVariableName)
            %
            % Inputs:
            %   obj
            %   fullVariableName        logical
            %       Whether to return the full name of persistent back-end
            %
            % Example:
            %   For SYSTEM, childContainers returns 'Channels'
            % -------------------------------------------------------------
            arguments
                obj
                fullVariableName        logical = false
            end

            out = arrayfun(@(x) x.parentContainer, obj.validChildTypes,...
                'UniformOutput', false);
            if ~isempty(out)
                out = string(out);
            else
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
            % Returns all members of an entity type within an experiment
            %
            % Syntax:
            %   out = collectAll(obj, experiment)
            % -------------------------------------------------------------
            assert(isSubclass(expt, 'aod.core.Experiment'),...
                'Must provide a subclass of aod.core.Experiment');

            out = expt.get(obj);
        end

        function out = empty(obj)
            % Returns an empty instance of the entity type
            %
            % Syntax:
            %   out = empty(obj)
            %
            % Notes:
            %   Experiment does not support empty and will return [].
            % -------------------------------------------------------------
            import aod.common.EntityTypes

            switch obj
                case EntityTypes.EXPERIMENT
                    out = [];
                case EntityTypes.SOURCE
                    out = aod.core.Source.empty();
                case EntityTypes.CALIBRATION
                    out = aod.core.Calibration.empty();
                case EntityTypes.SYSTEM
                    out = aod.core.System.empty();
                case EntityTypes.CHANNEL
                    out = aod.core.Channel.empty();
                case EntityTypes.DEVICE
                    out = aod.core.Device.empty();
                case EntityTypes.EXPERIMENTDATASET
                    out = aod.core.ExperimentDataset.empty();
                case EntityTypes.EPOCH
                    out = aod.core.Epoch.empty();
                case EntityTypes.EPOCHDATASET
                    out = aod.core.EpochDataset.empty();
                case EntityTypes.REGISTRATION
                    out = aod.core.Registration.empty();
                case EntityTypes.RESPONSE
                    out = aod.core.Response.empty();
                case EntityTypes.STIMULUS
                    out = aod.core.Stimulus.empty();
                case EntityTypes.ANNOTATION
                    out = aod.core.Annotation.empty();
                case EntityTypes.ANALYSIS
                    out = aod.core.Analysis.empty();
            end
        end

        function out = getCoreClassName(obj)
            % Returns the core class name (aod.core.X)
            %
            % Syntax:
            %   out = getCoreClassName(obj)
            % -------------------------------------------------------------

            if ~isscalar(obj)
                out = arrayfun(@(x) string(getCoreClassName(x)), obj);
                return
            end
            out = ['aod.core.', char(obj)];
        end

        function out = getPersistentClassName(obj)
            % Returns the persistent class name (aod.persistent.X)
            %
            % Syntax:
            %   out = getCoreClassName(obj)
            % -------------------------------------------------------------

            if ~isscalar(obj)
                out = arrayfun(@(x) string(getPersistentClassName(x)), obj);
                return
            end
            out = ['aod.persistent.', char(obj)];
        end
    end

    % HDF5 methods
    methods
        function hdfPath = getPath(obj, entity, manager, parentPath)
            % Returns HDF5 path for core interface entity
            %
            % Syntax:
            %   hdfPath = getPath(obj, entity, manager, parentPath)
            % -------------------------------------------------------------

            import aod.common.EntityTypes

            if obj == EntityTypes.EXPERIMENT
                hdfPath = '/Experiment';
                return
            end

            if ~isSubclass(entity, 'aod.core.Entity')
                error('getPath:InvalidEntity',...
                    'entity must be a subclass of aod.core.Entity');
            end

            assert(isSubclass(manager, 'aod.h5.EntityManager'),...
                'manager must be a subclass of aod.h5.EntityManager');
            if nargin < 4
                parentPath = obj.parentPath(entity, manager);
            end
            groupName = entity.groupName();

            hdfPath = h5tools.util.buildPath(...
                parentPath, obj.parentContainer(), groupName);
        end

        function hdfPath = parentPath(obj, entity, manager)
            % Returns parent HDF5 path for an entity
            %
            % Syntax:
            %   hdfPath = parentPath(obj, entity, manager)
            % -------------------------------------------------------------
            if nargin > 1
                assert(isSubclass(entity, 'aod.core.Entity'),...
                    'entity must be a subclass of aod.core.Entity');
            end
            if nargin > 2
                assert(isSubclass(manager, 'aod.h5.EntityManager'),...
                    'manager must be a subclass of aod.h5.EntityManager');
            end

            import aod.common.EntityTypes

            switch obj
                case EntityTypes.EXPERIMENT
                    hdfPath = [];
                case {EntityTypes.SYSTEM, EntityTypes.EPOCH, EntityTypes.ANNOTATION,...
                        EntityTypes.ANALYSIS, EntityTypes.CALIBRATION,...
                        EntityTypes.EXPERIMENTDATASET}
                    hdfPath = '/Experiment';
                case EntityTypes.SOURCE
                    hdfPath = manager.uuid2path(entity.Parent.UUID);
                otherwise
                    hdfPath = manager.uuid2path(entity.Parent.UUID);
            end
        end
    end

    methods (Static)
        function out = allContainerNames(obj) %#ok<INUSD>
            % Returns a list of all container names
            %
            % Syntax:
            %   out = getAllContainers(obj)
            % -------------------------------------------------------------
            out = ["Sources", "Calibrations",  "ExperimentDatasets",...
                 "Epochs", "Registrations", "Stimuli", "EpochDatasets",...
                "Systems", "Channels", "Devices", "Responses",...
                "Annotations", "Analyses"];
        end
    end


    % Builtin MATLAB methods
    methods
        function out = char(obj)
            % Returns char of entity type with correct capitalization
            %
            % Note:
            %   Necessary to avoid calling "string" bc infinite recursion
            % -------------------------------------------------------------

            if ~isscalar(obj)
                out = aod.util.arrayfun(@(x) char(x), obj);
                return
            end

            import aod.common.EntityTypes

            switch obj
                case EntityTypes.EXPERIMENT
                    out = 'Experiment';
                case EntityTypes.SOURCE
                    out = 'Source';
                case EntityTypes.CALIBRATION
                    out = 'Calibration';
                case EntityTypes.SYSTEM
                    out = 'System';
                case EntityTypes.CHANNEL
                    out = 'Channel';
                case EntityTypes.DEVICE
                    out = 'Device';
                case EntityTypes.ANNOTATION
                    out = 'Annotation';
                case EntityTypes.EXPERIMENTDATASET
                    out = 'ExperimentDataset';
                case EntityTypes.EPOCH
                    out = 'Epoch';
                case EntityTypes.STIMULUS
                    out = 'Stimulus';
                case EntityTypes.RESPONSE
                    out = 'Response';
                case EntityTypes.REGISTRATION
                    out = 'Registration';
                case EntityTypes.EPOCHDATASET
                    out = 'EpochDataset';
                case EntityTypes.ANALYSIS
                    out = 'Analysis';
            end
        end

        function out = string(obj)
            % Returns string of entity type with correct capitalization
            %
            % Note:
            %   Necessary to avoid calling "string" bc infinite recursion
            % -------------------------------------------------------------

            if ~isscalar(obj)
                out = aod.util.arrayfun(@(x) string(x), obj);
                return
            end

            out = sprintf("%s", char(obj));
        end
    end

    % Creation methods
    methods (Static)
        function out = getByClass(obj)
            % Returns the entity type of any subclass from either interface
            %
            % Syntax:
            %   out = getByClass(obj)
            % -------------------------------------------------------------
            arguments
                obj         {mustBeA(obj, ["aod.core.Entity","aod.persistent.Entity"])}
            end

            import aod.common.EntityTypes

            if isSubclass(obj, {'aod.core.Experiment', 'aod.persistent.Experiment'})
                out = EntityTypes.EXPERIMENT;
            elseif isSubclass(obj, {'aod.core.Annotation', 'aod.persistent.Annotation'})
                out = EntityTypes.ANNOTATION;
            elseif isSubclass(obj, {'aod.core.Analysis', 'aod.persistent.Analysis'})
                out = EntityTypes.ANALYSIS;
            elseif isSubclass(obj, {'aod.core.Source', 'aod.persistent.Source'})
                out = EntityTypes.SOURCE;
            elseif isSubclass(obj, {'aod.core.Calibration', 'aod.persistent.Calibration'})
                out = EntityTypes.CALIBRATION;
            elseif isSubclass(obj, {'aod.core.System', 'aod.persistent.System'})
                out = EntityTypes.SYSTEM;
            elseif isSubclass(obj, {'aod.core.Channel', 'aod.persistent.Channel'})
                out = EntityTypes.CHANNEL;
            elseif isSubclass(obj, {'aod.core.Device', 'aod.persistent.Device'})
                out = EntityTypes.DEVICE;
            elseif isSubclass(obj, {'aod.core.ExperimentDataset', 'aod.persistent.ExperimentDataset'})
                out = EntityTypes.EXPERIMENTDATASET;
            elseif isSubclass(obj, {'aod.core.Epoch', 'aod.persistent.Epoch'})
                out = EntityTypes.EPOCH;
            elseif isSubclass(obj, {'aod.core.EpochDataset', 'aod.persistent.EpochDataset'})
                out = EntityTypes.EPOCHDATASET;
            elseif isSubclass(obj, {'aod.core.Registration', 'aod.persistent.Registration'})
                out = EntityTypes.REGISTRATION;
            elseif isSubclass(obj, {'aod.core.Stimulus', 'aod.persistent.Stimulus'})
                out = EntityTypes.STIMULUS;
            elseif isSubclass(obj, {'aod.core.Response', 'aod.persistent.Response'})
                out = EntityTypes.RESPONSE;
            end
        end

        function obj = getFromSuperclass(className)
            % Get entity type from core class name
            %
            % Syntax:
            %   obj = aod.common.EntityTypes.getFromSuperclass(className)
            % -----------------------------------------------------------
            arguments
                className       string
            end

            superNames = string(superclasses(className));
            if ismember(superNames, "aod.persistent.Entity")
                error('getEntityTypeFromSuperclass:NotCoreEntity',...
                    'The class %s is not a subclass of aod.core.Entity', className);
            end

            coreEntities = aod.common.EntityTypes.all();
            coreClasses = getCoreClassName(coreEntities);
            obj = coreEntities(ismember(coreClasses, className));
            if isempty(obj)
                obj = coreEntities(ismember(coreClasses, superNames));
            end
        end

        function obj = get(entityName)
            % Initialize
            %
            % Description:
            %   Initialize from entity name as text (string or char) or
            %   from an object in the core or persistent interface
            %
            % Syntax:
            %   obj = aod.common.EntityTypes.get(entityName)
            %
            % Example:
            % % Return from name
            %   obj = aod.common.EntityTypes.get('epoch')
            %
            % % Return from class
            %   epoch = aod.core.Epoch(1);
            %   obj = aod.common.EntityTypes.get(epoch);
            %
            % Notes:
            %   For compatibility, if a aod.common.EntityTypes is passed as
            %   input, it will be returned without error
            %   Several abbreviations are also defined, see code
            % -------------------------------------------------------------

            import aod.common.EntityTypes;

            if isa(entityName, 'aod.common.EntityTypes')
                obj = entityName;
                return
            elseif aod.util.isEntitySubclass(entityName)
                obj = EntityTypes.getByClass(entityName);
                return
            end

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
                case {'expdataset', 'experimentdataset', 'expdata', 'experimentdata'}
                    obj = EntityTypes.EXPERIMENTDATASET;
                case {'epoch', 'epochs','ep'}
                    obj = EntityTypes.EPOCH;
                case {'epochdataset', 'epochdata', 'epochdset'}
                    obj = EntityTypes.EPOCHDATASET;
                case {'registration', 'registrations', 'reg'}
                    obj = EntityTypes.REGISTRATION;
                case {'response', 'responses', 'resp'}
                    obj = EntityTypes.RESPONSE;
                case {'stimulus', 'stimuli', 'stim'}
                    obj = EntityTypes.STIMULUS;
                case {'annotation', 'annotations'}
                    obj = EntityTypes.ANNOTATION;
                case {'analysis', 'analyses'}
                    obj = EntityTypes.ANALYSIS;
                otherwise
                    error('get:UnknownEntity',...
                        'Entity %s could not be matched to an EntityType', entityName);
            end
        end

        function entityTypes = all()
            % Return all entity types
            %
            % Syntax:
            %   entityTypes = aod.common.EntityTypes.all()
            % -------------------------------------------------------------

            import aod.common.EntityTypes

            entityTypes = [EntityTypes.EXPERIMENT, EntityTypes.SOURCE,...
                EntityTypes.SYSTEM, EntityTypes.CHANNEL, EntityTypes.DEVICE,...
                EntityTypes.CALIBRATION, EntityTypes.EXPERIMENTDATASET,...
                EntityTypes.EPOCH, EntityTypes.STIMULUS, EntityTypes.RESPONSE,...
                EntityTypes.REGISTRATION, EntityTypes.EPOCHDATASET,...
                EntityTypes.ANNOTATION, EntityTypes.ANALYSIS]';
        end

    end
end