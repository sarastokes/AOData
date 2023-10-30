classdef EntityFactory < handle
% Middle layer between persistent interface and HDF5 file
%
% Description:
%   A factory for creating entities from an HDF5 file and caching the
%   for faster interaction
%
% Constructor:
%   obj = aod.persistent.EntityFactory(hdfName)
%
% Static method access:
%   experiment = EntityFactory.init(hdfName)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        hdfName                 string
        % Handles changes made from persistent interface to HDF5 file
        persistor               aod.persistent.Persistor
        % Tracks all entities in the HDF5 file
        entityManager           aod.h5.EntityManager
        classManager            aod.infra.ClassRepository
        listeners               event.listener
        cache
    end

    methods
        function obj = EntityFactory(hdfName)
            obj.hdfName = hdfName;
            obj.entityManager = aod.h5.EntityManager(hdfName);
            obj.classManager = aod.infra.ClassRepository();
            obj.persistor = aod.persistent.Persistor(hdfName);

            obj.listeners = [...
                addlistener(obj.persistor, 'EntityChanged', @obj.onEntityChanged);...
                addlistener(obj.persistor, 'HdfPathChanged', @obj.onEntityRenamed)];

            obj.cache = containers.Map();
        end

        function e = getExperiment(obj)
            e  = obj.create('/Experiment');
        end

        function uuid = path2uuid(obj, hdfPath)
            T = obj.entityManager.table;
            idx = find(T.Path == hdfPath);
            if isempty(idx)
                uuid = [];
            else
                uuid = T.UUID(idx);
            end
        end

        function p = isCached(obj, UUID)
            if obj.cache.isKey(UUID)
                p = obj.cache(UUID);
            else
                p = [];
            end
        end

        function removeFromCache(obj, UUID)
            if ~isempty(obj.isCached(UUID))
                remove(obj.cache, UUID);
            end
        end

        function clearCache(obj)
            obj.cache = aod.common.KeyValueMap();
        end

        function e = create(obj, hdfPath)
            T = table(obj.entityManager);
            if ~ismember(hdfPath, T.Path)
                error("create:InvalidPath",...
                    'HDF path was invalid: %s', hdfPath);
            end
            uuid = T{T.Path == hdfPath, 'UUID'};
            if obj.cache.isKey(uuid)
                e = obj.cache(uuid);
                return
            end

            % Find persistent class and instantiate
            entityType = aod.common.EntityTypes.get(obj.entityManager.entityMap(uuid));
            persistentClass = str2func(entityType.getPersistentClassName());
            e = persistentClass(obj.hdfName, hdfPath, obj);

            obj.persistor.bind(e);
            obj.cache(uuid) = e;
        end
    end

    methods (Access = private)
        function onEntityChanged(obj, ~, evt)
            % Update the middle layer to reflect changes to an entity
            % -------------------------------------------------------------

            % Make sure irrelevant UUIDs are removed from the cache
            if strcmp(evt.Action, 'Remove')
                % Identify any child entities
                allChildren = obj.entityManager.getEntityChildren(evt.Entity);
                if numel(allChildren) > 0
                    warning('deleteEntity:Children',...
                        'This action will also delete %u child entities', ...
                        numel(allChildren));
                end
                % Remove the entity and all children from cache
                obj.removeFromCache(evt.Entity.UUID);
                if numel(allChildren) > 0
                    for i = 1:numel(allChildren)
                        %! Check for softlinks
                        obj.removeFromCache(obj.entityManager.path2uuid(allChildren(i)));
                    end
                end
                % Reload parent entity
                evt.Entity.Parent.reload();
            elseif strcmp(evt.Action, 'Replace')
                evt.Entity.reload();
            end

            % Refresh the list of UUIDs
            obj.entityManager.collect();
        end

        function onEntityReplaced(obj, ~, evt)

        end

        function onEntityRenamed(obj, ~, evt)
            % Handles side-effects of a renamed group and the path change
            %
            % HDF5 group renaming is a nightmare and here I've chosen to
            % minimize disruption to user over minimizing complexity
            % -------------------------------------------------------------

            % Refresh the list of UUIDs
            obj.entityManager.collect();
            T = obj.entityManager.table;

            % Update the entity's HDF5 path
            evt.Entity.changeHdfPath(evt.NewPath);
            evt.Entity.reload();

            % Get the modified entity and all children
            idx = startsWith(T.Path, evt.NewPath);
            allPaths = T{idx, "Path"};
            allUUIDs = T{idx, "UUID"};

            % Log all HDF paths with an updated HDF5 path, for reload
            updatedEntities = string.empty();
            % Change the HDF path of all cached entities (original + child)
            % Entities that are not cached will be loaded with correct path
            for i = 1:numel(allPaths)
                entity = obj.isCached(allUUIDs(i));
                if ~isempty(entity)
                    entity.changeHdfPath(strrep(entity.hdfPath, evt.OldPath, evt.NewPath));
                    updatedEntities = cat(1, updatedEntities, entity.hdfPath);
                end
            end

            % Update entity's parent containers to reflect new HDF5 paths
            evt.Entity.Parent.reload();

            % Collect all softlinks. Softlink sources are changed by
            % H5L.move, but softlink targets are not and must be edited
            links = aod.h5.collectExperimentLinks(obj.hdfName, true);
            for i = 1:numel(allPaths)
                % Check if original HDF path is a softlink target
                idx = find(links.Target == strrep(allPaths(i), evt.NewPath, evt.OldPath));
                if isempty(idx)
                    continue
                end
                sourcePaths = links{idx, "Location"};
                % Entities cannot be loaded until link is fixed so correct
                % through h5tools rather than persistent interface
                for j = 1:numel(sourcePaths)
                    h5tools.deleteObject(obj.hdfName, sourcePaths(j));
                    [sourcePath, sourceLink] = h5tools.util.splitPath(sourcePaths(j));
                    h5tools.writelink(obj.hdfName, sourcePath, sourceLink, allPaths(i));
                    updatedEntities = cat(1, updatedEntities, sourcePaths);
                end
            end

            % Now we need to reload any cached entities with a changed
            % softlink - reload is preferable to deletion because user may
            % have existing handles to these entities
            updatedEntities = unique(updatedEntities);
            for i = 1:numel(updatedEntities)
                uuid = obj.path2uuid(updatedEntities(i));
                e = obj.isCached(uuid);
                if isempty(e)
                    continue
                end
                e.reload();
            end
        end
    end

    methods (Static)
        function experiment = init(hdfName)
            obj = aod.persistent.EntityFactory(hdfName);
            experiment = obj.getExperiment();
        end
    end
end