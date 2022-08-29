classdef EntityFactory < handle 
% ENTITYFACTORY
%
% Description:
%   A factory for creating persistent entities
%
% Constructor:
%   obj = EntityFactory(hdfName)
% -------------------------------------------------------------------------

    properties (Access = private)
        hdfName 
        entityManager 
        cache 
    end

    methods
        function obj = EntityFactory(hdfName)
            obj.hdfName = hdfName;
            obj.entityManager = aod.h5.EntityManager(hdfName);
            obj.cache = containers.Map();
        end

        function e = create(obj, hdfPath)
            uuid = h5readatt(obj.hdfName, hdfPath, 'UUID');
            if obj.cache.isKey(uuid)
                e = obj.cache(uuid);
                return
            end

            entityType = EM.entityMap(uuid);
            switch entityType 
                case "EXPERIMENT"
                    e = aod.core.persistent.Experiment(obj.hdfFile, hdfPath, obj);
                case "SYSTEM"
                    e = aod.core.persistent.System(obj.hdfFile, hdfPath, obj);
                case "CHANNEL"
                    e = aod.core.persistent.Channel(obj.hdfFile, hdfPath, obj);
                case "DEVICE"
                    e = aod.core.persistent.Device(obj.hdfFile, hdfPath, obj);
                otherwise
                    error("EntityFactorycreate:UnrecognizedEntity",...
                        "Did not recognize entity name: %s", entityType);
            end
            obj.cache(uuid) = e;
        end
    end
end 