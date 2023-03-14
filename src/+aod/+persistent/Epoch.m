classdef Epoch < aod.persistent.Entity & matlab.mixin.Heterogeneous & dynamicprops
% An Epoch within an HDF5 file
%
% Description:
%   Represents a persisted Epoch in an HDF5 file
%
% Parent:
%   aod.persistent.Entity, matlab.mixin.Heterogeneous, dynamicprops
%
% Constructor:
%   obj = aod.persistent.Epoch(hdfFile, pathName, factory)
%
% See also:
%   aod.core.Epoch

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        ID
        startTime   
        Timing 
        Source 
        System 

        EpochDatasetsContainer
        RegistrationsContainer
        ResponsesContainer
        StimuliContainer
    end

    methods
        function obj = Epoch(hdfFile, pathName, factory)
            obj = obj@aod.persistent.Entity(hdfFile, pathName, factory);
        end
    end

    % Addition methods
    methods (Sealed)
        function add(obj, entity)
            % Add a new entity to the Epoch
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
                    'Entity must be EpochDataset, Registration, Response and Stimulus');
            end

            entity.setParent(obj);
            obj.addEntity(entity);
        end
    end

    methods (Sealed, Access = protected)
        function populate(obj)
            populate@aod.persistent.Entity(obj);
            
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
            obj.EpochDatasetsContainer = obj.loadContainer('EpochDatasets');
            obj.RegistrationsContainer = obj.loadContainer('Registrations');
            obj.ResponsesContainer = obj.loadContainer('Responses');
            obj.StimuliContainer = obj.loadContainer('Stimuli');
        end
    end
    
    % Container abstraction methods
    methods (Sealed)
        function out = EpochDatasets(obj, idx)
            if nargin < 2 
                idx = 0;
            end
            out = [];
            for i = 1:numel(obj)
                out = cat(1, out, obj(i).EpochDatasetsContainer(idx));
            end
        end

        function out = Registrations(obj, idx, propName)
            if nargin < 2
                idx = 0;
            end
            out = [];
            for i = 1:numel(obj)
                out = cat(1, out, obj(i).RegistrationsContainer(idx));
            end
            if nargin > 2
                if isscalar(out(1).(propName))
                    out = cat(1, out.(propName));
                end
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