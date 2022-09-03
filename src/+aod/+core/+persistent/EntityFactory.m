classdef EntityFactory < handle 
% ENTITYFACTORY
%
% Description:
%   A factory for creating persistent entities
%
% Constructor:
%   obj = EntityFactory(hdfName)
%
% Static method access:
%   experiment = EntityFactory.init(hdfName)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        hdfName
        persistor
        entityManager 
        cache 
    end

    methods
        function obj = EntityFactory(hdfName)
            obj.hdfName = hdfName;
            obj.entityManager = aod.h5.EntityManager(hdfName);
            obj.persistor = aod.core.persistent.Persistor(hdfName);
            obj.cache = containers.Map();
        end

        function e = getExperiment(obj)
            e  = obj.create('/Experiment');
        end

        function clearCache(obj)
            obj.cache = aod.util.Parameters();
            obj.persistor.unbind();
        end

        function e = create(obj, hdfPath)
            T = table(obj.entityManager);
            uuid = T{T.Path == hdfPath, 'UUID'};
            if obj.cache.isKey(uuid)
                e = obj.cache(uuid);
                return
            end

            entityType = obj.entityManager.entityMap(uuid);
            switch entityType 
                case "EXPERIMENT"
                    e = aod.core.persistent.Experiment(obj.hdfName, hdfPath, obj);
                case "ANALYSIS"
                    e = aod.core.persistent.Analysis(obj.hdfName, hdfPath, obj);
                case "SOURCE"
                    e = aod.core.persistent.Source(obj.hdfName, hdfPath, obj);
                case "SYSTEM"
                    e = aod.core.persistent.System(obj.hdfName, hdfPath, obj);
                case "CHANNEL"
                    e = aod.core.persistent.Channel(obj.hdfName, hdfPath, obj);
                case "DEVICE"
                    e = aod.core.persistent.Device(obj.hdfName, hdfPath, obj);
                case "CALIBRATION"
                    e = aod.core.persistent.Calibration(obj.hdfName, hdfPath, obj);
                case "REGION"
                    e = aod.core.persistent.Region(obj.hdfName, hdfPath, obj);
                case "EPOCH"
                    e = aod.core.persistent.Epoch(obj.hdfName, hdfPath, obj);
                case "RESPONSE"
                    e = aod.core.persistent.Response(obj.hdfName, hdfPath, obj);
                case "STIMULUS"
                    e = aod.core.persistent.Stimulus(obj.hdfName, hdfPath, obj);
                case 'REGISTRATION'
                    e = aod.core.persistent.Registration(obj.hdfName, hdfPath, obj);
                case 'DATASET'
                    e = aod.core.persistent.Dataset(obj.hdfName, hdfPath, obj);
                otherwise
                    error("EntityFactory:UnrecognizedEntity",...
                        "Did not recognize entity name: %s", entityType);
            end
            obj.persistor.bind(e);
            obj.cache(uuid) = e;
        end
    end

    methods (Static)
        function experiment = init(hdfName)
            obj = aod.core.persistent.EntityFactory(hdfName);
            experiment = obj.getExperiment();
        end
    end
end 