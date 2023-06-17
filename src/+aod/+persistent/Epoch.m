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

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = {?aod.persistent.Entity, ?aod.persistent.Epoch})
        ID
        startTime   
        Timing 
        Source 
        System 
    end

    properties (SetAccess = private)
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
        function tf = has(obj, entityType, varargin)
            % Search Epoch's child entities and return if matches exist
            %
            % Description:
            %   Search all entities of a specific type that match the given
            %   criteria (see Epoch.get) and return whether matches exist
            %
            % Syntax:
            %   tf = has(obj, entityType, varargin)
            %
            % Inputs:
            %   Identical to aod.persistent.Epoch.get()
            % -------------------------------------------------------------

            tf = ~isempty(obj.get(entityType, varargin{:}));
        end

        function out = get(obj, entityType, varargin)
            % Search Epoch's child entities and return matches
            %
            % Description:
            %   Search all entities of a specific type that match the given
            %   criteria (described below in examples)
            %
            % Inputs:
            %   entityType          char or aod.common.EntityTypes
            % Optional inputs:
            %   One or more cells containing queries (TODO: doc)
            % -------------------------------------------------------------
        
            import aod.common.EntityTypes

            entityType = EntityTypes.get(entityType);
            if ~ismember(entityType, obj.entityType.validChildTypes())
                error('get:InvalidEntityType',...
                    'Entity must be EpochDataset, Registration, Response and Stimulus');
            end

            group = obj.(entityType.parentContainer());

            if nargin > 2 && ~isempty(group)
                out = aod.common.EntitySearch.go(group, varargin{:});
            else
                out = group;
            end
        end

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

            import aod.common.EntityTypes

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
            obj.ID = obj.assignProp("ID");
            obj.startTime = obj.assignProp("startTime");
            obj.Timing = obj.assignProp("Timing");
            obj.populateDatasetsAsDynProps();

            % LINKS
            obj.Source = obj.loadLink("Source");
            obj.System = obj.loadLink("System");
            obj.populateLinksAsDynProps();
        end

        function populateContainers(obj)
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