classdef Experiment < aod.persistent.Entity & dynamicprops
% An Experiment in an HDF5 file
%
% Description:
%   Represents a persisted Experiment in an HDF5 file
%
% Parent:
%   aod.persistent.Entity, matlab.mixin.Heterogeneous, dynamicprops
%
% Constructor:
%   obj = aod.persistent.Experiment(hdfFile, pathName, factory)
%
% See also:
%   aod.core.Experiment

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        homeDirectory               char
        experimentDate (1,1)        datetime
        epochIDs (1,:)              

        AnalysesContainer         
        EpochsContainer        
        SourcesContainer                 
        AnnotationsContainer                 
        CalibrationsContainer            
        SystemsContainer      
        
        Code                        table
    end

    properties (Dependent)
        numEpochs
    end

    methods
        function obj = Experiment(hdfName, pathName, factory)
            obj = obj@aod.persistent.Entity(hdfName, pathName, factory);
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
            % Add a new entity to the Experiment
            %
            % Syntax:
            %   add(obj, entity)
            % -------------------------------------------------------------
            arguments
                obj
                entity      {mustBeA(entity, 'aod.core.Entity')}
            end

            if ~isscalar(entity)
                arrayfun(@(x) add(obj, x), entity);
                return
            end

            import aod.core.EntityTypes

            entityType = EntityTypes.get(entity);
            if ~ismember(entityType, obj.entityType.validChildTypes())
                error('add:InvalidEntityType',...
                    'Only Analysis, Calibration, Epoch, Annotation, System and Source can be added to Experiment');
            end

            entity.setParent(obj);
            obj.addEntity(entity);
        end
    end

    methods (Access = protected)
        function populate(obj)
            populate@aod.persistent.Entity(obj);
 
            % Datasets
            obj.experimentDate = obj.loadDataset('experimentDate');
            obj.homeDirectory = obj.loadDataset('homeDirectory');
            obj.epochIDs = obj.loadDataset('epochIDs');
            obj.Code = obj.loadDataset('Code');
            obj.setDatasetsToDynProps();

            % Links
            obj.setLinksToDynProps();

            % Containers
            obj.AnalysesContainer = obj.loadContainer('Analyses');
            obj.CalibrationsContainer = obj.loadContainer('Calibrations');
            obj.EpochsContainer = obj.loadContainer('Epochs');
            obj.AnnotationsContainer = obj.loadContainer('Annotations');
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

        function out = Annotations(obj, idx)
            if nargin < 2
                idx = 0;
            end
            out = [];
            for i = 1:numel(obj)
                out = cat(1, out, obj(i).AnnotationsContainer(idx));
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