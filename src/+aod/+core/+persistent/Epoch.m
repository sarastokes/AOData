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
            populate@aod.core.persistent.Entity(obj);
            
            % DATASETS
            obj.ID = obj.loadDataset("ID");
            obj.startTime = obj.loadDataset("startTime");
            obj.Timing = obj.loadDataset("Timing");
            obj.setDatasetsToDynProps();

            % LINKS
            obj.Source = obj.loadLink("Source");
            obj.System = obj.loadLink("System");
            obj.setLinksToDynProps();

            % CONTAINERS
            obj.Datasets = obj.loadContainer('Datasets');
            obj.Registrations = obj.loadContainer('Registrations');
            obj.Responses = obj.loadContainer('Responses');
            obj.Stimuli = obj.loadContainer('Stimuli');
        end
    end
end 