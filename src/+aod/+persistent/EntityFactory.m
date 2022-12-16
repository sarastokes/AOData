classdef EntityFactory < handle 
% ENTITYFACTORY
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

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        hdfName
        persistor
        entityManager
        classManager
        cache 
    end

    methods
        function obj = EntityFactory(hdfName)
            obj.hdfName = hdfName;
            obj.entityManager = aod.h5.EntityManager(hdfName);
            obj.classManager = aod.infra.ClassRepository();
            obj.persistor = aod.persistent.Persistor(hdfName);
            addlistener(obj.persistor, 'EntityChanged', @obj.onEntityChanged);

            obj.cache = containers.Map();
        end

        function e = getExperiment(obj)
            e  = obj.create('/Experiment');
        end

        function clearCache(obj)
            obj.cache = aod.util.Parameters();
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

            className = T{T.Path == hdfPath, 'Class'};
            entityType = aod.core.EntityTypes.init(obj.entityManager.entityMap(uuid));

            mirrorFcn = str2func(aod.infra.findMirror(...
                entityType, className, obj.classManager));
            e = mirrorFcn(obj.hdfName, hdfPath, obj);

            obj.persistor.bind(e);
            obj.cache(uuid) = e;
        end
    end

    methods (Access = private)
        function onEntityChanged(obj, ~, evt)
            obj.entityManager.collect();
            if strcmp(evt.Action, 'Remove')
                remove(obj.cache, evt.UUID);
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