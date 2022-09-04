classdef Epoch < aod.core.persistent.Entity & dynamicprops

    properties (SetAccess = protected)
        ID(1,1)
        startTime(1,1)                  datetime 

        Source 
        System 

        DatasetsContainer
        RegistrationsContainer
        ResponsesContainer
        StimuliContainer
        Timing
    end

    methods
        function obj = Epoch(hdfFile, hdfPath, factory)
            obj = obj@aod.core.persistent.Entity(hdfFile, hdfPath, factory);
        end
    end

    methods (Sealed, Access = protected)
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
            obj.DatasetsContainer = obj.loadContainer('Datasets');
            obj.RegistrationsContainer = obj.loadContainer('Registrations');
            obj.ResponsesContainer = obj.loadContainer('Responses');
            obj.StimuliContainer = obj.loadContainer('Stimuli');
        end
    end
    
    % Container abstraction methods
    methods (Sealed)
        function out = Datasets(obj, idx)
            if nargin < 2 
                idx = 0;
            end
            out = [];
            for i = 1:numel(obj)
                out = cat(1, out, obj(i).DatasetsContainer(idx));
            end
        end

        function out = Registrations(obj, idx)
            if nargin < 2
                idx = 0;
            end
            out = [];
            for i = 1:numel(obj)
                out = cat(1, out, obj(i).RegistrationsContainer(idx));
            end
        end

        function out = Responses(obj, idx)
            if nargin < 2
                idx = 0;
            end
            out = [];
            for i = 1:numel(obj)
                out = cat(1, out, obj(i).ResponsesContainer(idx));
            end
        end

        function out = Stimuli(obj, idx)
            if nargin < 2
                idx = 0;
            end
            out = [];
            for i = 1:numel(obj)
                out = cat(1, out, obj(i).StimuliContainer(idx));
            end
        end
    end
end 