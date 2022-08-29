classdef Persistor < handle 

    properties 
        hdfName 
        entityManager 
        Experiment
    end

    properties (SetAccess = protected)
        entityFactory
    end

    properties (Access = private)
        entityTypes
        cache
    end

    methods
        function obj = Persistor(hdfName, entityTypes)
            assert(isfile(hdfName), 'HDF name must be an existing HDF5 file');
            obj.hdfName = hdfName;

            if nargin < 2
                obj.entityTypes = entityTypes;
            end
            obj.entityFactory = @(x)obj.entityTypes.(x);
            

            obj.entityManager = aod.h5.EntityManager(hdfName);
            obj.cache = containers.Map();

            obj.getExperiment();
        end

        
        function out = getEntity(obj, hdfPath)
            entityType = h5readatt(obj.hdfName, hdfPath, 'EntityType');
            entityType = obj.entityFactory(entityType);

        end
    end
end 