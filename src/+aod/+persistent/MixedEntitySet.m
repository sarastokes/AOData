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
        Experiments         {aod.util.mustBeEntityType(Experiments, 'Experiment')} = aod.persistent.Experiment.empty()    
        Sources             {aod.util.mustBeEntityType(Sources, 'Source')} = aod.persistent.Source.empty()
        Systems             {aod.util.mustBeEntityType(Systems, 'System')} = aod.persistent.System.empty()
        Channels            {aod.util.mustBeEntityType(Channels, 'Channel')} = aod.persistent.Channel.empty() 
        Devices             {aod.util.mustBeEntityType(Devices, 'Device')} = aod.persistent.Device.empty() 
        Calibrations        {aod.util.mustBeEntityType(Calibrations, 'Calibration')} = aod.persistent.Calibration.empty()
        Epochs              {aod.util.mustBeEntityType(Epochs, 'Epoch')} = aod.persistent.Epoch.empty()
        EpochDatasets       {aod.util.mustBeEntityType(EpochDatasets, 'EpochDataset')} = aod.persistent.EpochDataset.empty()
        Registrations       {aod.util.mustBeEntityType(Registrations, 'Registration')} = aod.persistent.Registration.empty()
        Responses           {aod.util.mustBeEntityType(Responses, 'Response')} = aod.persistent.Response.empty()
        Stimuli             {aod.util.mustBeEntityType(Stimuli, 'Stimulus')} = aod.persistent.Stimulus.empty()
        ExperimentDatasets  {aod.util.mustBeEntityType(ExperimentDatasets, 'ExperimentDataset')} = aod.persistent.ExperimentDataset.empty();       
        Annotations         {aod.util.mustBeEntityType(Annotations, 'Annotation')} = aod.persistent.Annotation.empty()   
        Analyses            {aod.util.mustBeEntityType(Analyses, 'Analysis')} = aod.persistent.Analysis.empty()
    end

    properties (Hidden, Access=protected)
        entityClass
    end

    methods 
        function obj = MixedEntitySet()
            obj.entityClass = 'aod.persistent.Entity';
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
            
            if ~isSubclass(entity, obj.entityClass)
                error('add:InvalidInput',... 
                    'Input must be subclass of %s', obj.entityClass);
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
            %   entityTypes         aod.common.EntityTypes
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