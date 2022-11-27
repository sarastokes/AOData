classdef Experiment < aod.persistent.Entity & dynamicprops
% EXPERIMENT
%
% Description:
%   Represents a persisted Experiment in an HDF5 file
%
% Parent:
%   aod.persistent.Entity
%   matlab.mixin.Heterogeneous
%   dynamicprops
%
% Constructor:
%   obj = Experiment(hdfFile, hdfPath, factory)
%
% See also:
%   aod.core.Experiment
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        homeDirectory           char
        experimentDate(1,1)     datetime
        epochIDs

        AnalysesContainer         
        EpochsContainer        
        SourcesContainer                 
        SegmentationsContainer                 
        CalibrationsContainer            
        SystemsContainer                 
    end

    properties (Dependent)
        numEpochs
    end

    methods
        function obj = Experiment(hdfName, hdfPath, factory)
            obj = obj@aod.persistent.Entity(hdfName, hdfPath, factory);
        end

        function value = get.numEpochs(obj)
            value = numel(obj.epochIDs);
        end
    end

    % Core methods
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

            evtData = aod.persistent.events.DatasetEvent(...
                'homeDirectory', homeDirectory, obj.homeDirectory);
            notify(obj, 'DatasetChanged', evtData);

            obj.homeDirectory = homeDirectory;
        end

        function add(obj, entity)
            arguments
                obj
                entity      {mustBeA(entity, 'aod.core.Entity')}
            end

            if ~isscalar(entity)
                arrayfun(@(x) add(obj, x), entity);
                return
            end

            import aod.core.EntityTypes
        
            switch entity.entityType
                case EntityTypes.ANALYSIS
                    entity.setParent(obj);
                    obj.addEntity(entity);
                case EntityTypes.CALIBRATION
                    entity.setParent(obj);
                    obj.addEntity(entity);
                case EntityTypes.EPOCH
                    entity.setParent(obj);
                    obj.addEntity(entity);
                case EntityTypes.SEGMENTATION
                    entity.setParent(obj);
                    obj.addEntity(entity);
                case EntityTypes.SOURCE
                    entity.setParent(obj);
                    obj.addEntity(entity);
                case EntityTypes.SYSTEM
                    entity.setParent(obj);
                    obj.addEntity(entity);
                otherwise
                    error('Experiment_add:InvalidEntityType',...
                        'Only Analysis, Calibration, Epoch, Segmentation, System and Source can be added to Experiment')
            end
        end
    end

    methods (Access = protected)
        function populate(obj)
            populate@aod.persistent.Entity(obj);
 
            % Datasets
            obj.experimentDate = obj.loadDataset('experimentDate');
            obj.homeDirectory = obj.loadDataset('homeDirectory');
            obj.epochIDs = obj.loadDataset('epochIDs');
            obj.setDatasetsToDynProps();

            % Links
            obj.setLinksToDynProps();

            % Containers
            obj.AnalysesContainer = obj.loadContainer('Analyses');
            obj.CalibrationsContainer = obj.loadContainer('Calibrations');
            obj.EpochsContainer = obj.loadContainer('Epochs');
            obj.SegmentationsContainer = obj.loadContainer('Segmentations');
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

        function out = Segmentations(obj, idx)
            if nargin < 2
                idx = 0;
            end
            out = [];
            for i = 1:numel(obj)
                out = cat(1, out, obj(i).SegmentationsContainer(idx));
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