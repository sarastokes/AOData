classdef Epoch < aod.core.persistent.Entity & dynamicprops 

    properties (SetAccess = protected)
        ID(1,1)
        startTime(1,1)                  datetime 

        Source 
        System 

        Datasets
        Registrations
        Responses
        Stimuli
        Timing
    end

    methods
        function obj = Epoch(hdfFile, hdfPath, factory)
            obj = obj@aod.core.persistent.Entity(hdfFile, hdfPath, factory);
        end
    end

    methods (Access = protected)
        function populate(obj)
            [dsetNames, linkNames] = populate@aod.core.persistent.Entity(obj);
            
            % DATASETS
            if ismember("ID", dsetNames)
                obj.ID = aod.h5.readDatasetByType(obj.hdfName, obj.hdfPath, "ID");
            end
            
            if ismember("startTime", dsetNames)
                obj.startTime = aod.h5.readDatasetByType(obj.hdfName, obj.hdfPath, "startTime");
            end

            obj.setDatasetsToDynProps();

            % LINKS
            obj.Source = obj.createFromLink(linkNames, "Source");
            obj.System = obj.loadLink(linkNames, "System");
            obj.setLinksToDynProps();

            % GROUPS
            tinfo = h5info(aod.h5.HDF5.buildPath(obj.hdfName, 'Timing'));
            if ~isempty(tinfo.Datasets)
                obj.Timing = obj.factory.create(aod.h5.HDF5.buildPath(obj.hdfName, 'Timing'));
            end

            % CONTAINERS
            obj.Datasets = aod.core.persistent.EntityContainer(...
                aod.h5.HDF5.buildPath(obj.hdfPath, 'Datasets'), obj.factory);
            obj.Registrations = aod.core.persistent.EntityContainer(...
                aod.h5.HDF5.buildPath(obj.hdfPath, 'Registrations'), obj.factory);
            obj.Responses = aod.core.persistent.EntityContainer(...
                aod.h5.HDF5.buildPath(obj.hdfPath, 'Responses'), obj.factory);
            obj.Stimuli = aod.core.persistent.EntityContainer(...
                aod.h5.HDF5.buildPath(obj.hdfPath, 'Stimuli'), obj.factory);
        end
    end
end 