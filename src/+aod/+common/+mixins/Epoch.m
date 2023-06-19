classdef Epoch < handle 
%
% See also:
%   aod.core.Epoch, aod.persistent.Epoch

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    methods 
        function add(obj, entity)
            % Add an entity to the Epoch 
            %
            % Description:
            %   Add a new entity to the epoch
            %
            % Syntax:
            %   add(obj, entity)
            %
            % Notes: Only entities contained by Epoch can be added:
            %   EpochDataset, Response, Registration, Stimulus
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
        end
    end
end