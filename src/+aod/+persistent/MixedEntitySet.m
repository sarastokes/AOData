classdef MixedEntitySet < handle & matlab.mixin.CustomDisplay
% Mixed array of AOData persistent entities
%
% Parent:
%   handle, matlab.mixin.CustomDisplay
%
% Constructor:
%   obj = aod.api.MixedEntitySet()
%
% Notes:
%   CustomDisplay will only list entity types present in the object
%

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------
    
    properties (SetAccess = protected)
        Experiments             aod.persistent.Experiment
        Sources                 aod.persistent.Source 
        Systems                 aod.persistent.System
        Channels                aod.persistent.Channel 
        Devices                 aod.persistent.Device 
        Calibrations            aod.persistent.Calibration 
        Epochs                  aod.persistent.Epoch 
        EpochDatasets           aod.persistent.EpochDataset 
        Registrations           aod.persistent.Registration 
        Responses               aod.persistent.Response 
        Stimuli                 aod.persistent.Stimulus 
        ExperimentDatasets      aod.persistent.ExperimentDataset 
        Annotations             aod.persistent.Annotation
        Analyses                aod.persistent.Analysis 
    end

    methods 
        function obj = MixedEntitySet()
            % Do nothing on initialization
        end

        function add(obj, entity)
            % Add new entities to the MixedEntitySet
            %
            % Syntax:
            %   add(obj, entity)
            %
            % Inputs:
            %   entity          aod.persistent.Entity subclass
            %       One or more new entities of the same type
            % -------------------------------------------------------------
            
            if ~isSubclass(entity, 'aod.persistent.Entity')
                error('add:InvalidInput',... 
                    'Input must be subclass of aod.persistent.Entity');
            end

            containerName = entity(1).entityType.parentContainer();
            obj.(containerName) = cat(1, obj.(containerName), entity);
        end

        function entityTypes = whichEntities(obj)
            % Get the entity types in the MixedEntitySet
            %
            % Syntax:
            %   entityTypes = whichEntities(obj)
            %
            % Output:
            %   entityTypes         aod.core.EntityTypes
            %       Entity types present in MixedEntitySet
            % -------------------------------------------------------------

            props = properties(obj);
            entityTypes = [];
            for i = 1:numel(props)
                entity = obj.(props{i});
                if ~isempty(entity)
                    entityTypes = cat(1, entityTypes, entity(1).entityType);
                end
            end
        end
    end

    % matlab.mixin.CustomDisplay
    methods (Access = protected)
        function header = getHeader(obj)
            % Defines custom header for display
            if ~isscalar(obj) || ~isempty(obj)
                header = getHeader@matlab.mixin.CustomDisplay(obj);
            else
                headerStr = matlab.mixin.CustomDisplay.getClassNameForHeader(obj);
                if isempty(obj)
                    header = sprintf('%s (empty)\n', headerStr);
                else
                    header = sprintf('%s with %u entity types:',...
                        headerStr, numel(obj.whichEntities()));
                end
            end
        end

        function propgrp = getPropertyGroups(obj)
            % Defines custom property group for dislay
            propgrp = getPropertyGroups@matlab.mixin.CustomDisplay(obj);

            if ~isscalar(obj)
                return
            end

            f = fieldnames(propgrp.PropertyList);
            idx = structfun(@isempty, propgrp.PropertyList);
            for i = 1:propgrp.NumProperties
                if idx(i)
                    propgrp.PropertyList = rmfield(propgrp.PropertyList, f{i});
                end
            end
        end
    end

    methods 
        function tf = isempty(obj)
            props = properties(obj);
            tf = true;
            % Set to false and exit out if a property isn't emtpy
            for i = 1:numel(props)
                if ~isempty(obj.(props{i}))
                    tf = false;
                    return
                end
            end
        end
    end
end 