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
            obj.ID = obj.loadDataset(dsetNames, "ID");
            obj.startTime = obj.loadDataset(dsetNames, "startTime");
            obj.Timing = obj.loadDataset(dsetNames, "Timing");
            obj.setDatasetsToDynProps();

            % LINKS
            obj.Source = obj.loadLink(linkNames, "Source");
            obj.System = obj.loadLink(linkNames, "System");
            obj.setLinksToDynProps();

            % CONTAINERS
            obj.Datasets = obj.loadContainer('Datasets');
            obj.Registration = obj.loadContainer('Registration');
            obj.Responses = obj.loadContainer('Responses');
            obj.Stimuli = obj.loadContainer('Stimuli');
        end
    end
end 