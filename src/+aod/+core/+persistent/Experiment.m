classdef Experiment < aod.core.persistent.Entity & dynamicprops

    properties (SetAccess = protected)
        homeDirectory           char
        experimentDate(1,1)     datetime
        epochIDs

        AnalysesContainer         
        EpochsContainer        
        SourcesContainer                 
        RegionsContainer                 
        CalibrationsContainer            
        SystemsContainer                 
    end

    properties (Dependent)
        numEpochs
    end

    methods
        function obj = Experiment(hdfName, hdfPath, factory)
            obj = obj@aod.core.persistent.Entity(hdfName, hdfPath, factory);
        end

        function value = get.numEpochs(obj)
            value = numel(obj.epochIDs);
        end
    end

    methods
        function setHomeDirectory(obj, homeDirectory)
            % SETHOMEDIRECTORY
            %
            % Description:
            %   Change the experiment's home directory
            %
            % Syntax:
            %   setHomeDirectory(obj, homeDirectory)
            % -------------------------------------------------------------
            arguments
                obj
                homeDirectory           string
            end

            evtData = aod.h5.events.DatasetEvent('homeDirectory',...
                homeDirectory, obj.homeDirectory);
            notify(obj, 'ChangedDataset', evtData);

            obj.homeDirectory = homeDirectory;
        end
    end

    methods (Access = protected)
        function populate(obj)
            populate@aod.core.persistent.Entity(obj);
 
            obj.experimentDate = obj.loadDataset('experimentDate');
            obj.homeDirectory = obj.loadDataset('homeDirectory');
            obj.epochIDs = obj.loadDataset('epochIDs');
            obj.setDatasetsToDynProps();

            obj.setLinksToDynProps();

            obj.AnalysesContainer = obj.loadContainer('Analyses');
            obj.CalibrationsContainer = obj.loadContainer('Calibrations');
            obj.EpochsContainer = obj.loadContainer('Epochs');
            obj.RegionsContainer = obj.loadContainer('Regions');
            obj.SourcesContainer = obj.loadContainer('Sources');
            obj.SystemsContainer = obj.loadContainer('Systems');
        end
    end

    % Container abstraction methods
    methods (Sealed)
        function out = Analyses(obj, idx)
            if nargin < 2
                idx = 0;
            end
            out = [];
            for i = 1:numel(obj)
                out = cat(1, out, obj(i).AnalysesContainer(idx));
            end
        end

        function out = Calibrations(obj, idx)
            if nargin < 2 
                idx = 0;
            end
            out = [];
            for i = 1:numel(obj)
                out = cat(1, out, obj(i).CalibrationsContainer(idx));
            end
        end

        function out = Epochs(obj, idx)
            if nargin < 2
                idx = 0;
            end
            out = [];
            for i = 1:numel(obj)
                out = cat(1, out, obj(i).EpochsContainer(idx));
            end
        end

        function out = Regions(obj, idx)
            if nargin < 2
                idx = 0;
            end
            out = [];
            for i = 1:numel(obj)
                out = cat(1, out, obj(i).RegionsContainer(idx));
            end
        end

        function out = Sources(obj, idx)
            if nargin < 2
                idx = 0;
            end
            out = [];
            for i = 1:numel(obj)
                out = cat(1, out, obj(i).SourcesContainer(idx));
            end
        end

        function out = Systems(obj, idx)
            if nargin < 2
                idx = 0;
            end
            out = [];
            for i = 1:numel(obj)
                out = cat(1, out, obj(i).SystemsContainer(idx));
            end
        end
    end
end