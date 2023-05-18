classdef (ConstructOnLoad) GroupEvent < event.EventData
% GROUPEVENT
%
% Description:
%   An event triggered when an HDF5 group is added/changed/removed
%
% Superclass:
%   event.EventData
%
% Constructor:
%   obj = aod.persistent.events.GroupEvent(entity, action, newEntity)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties
        Entity
        Action
        NewEntity
    end

    methods
        function obj = GroupEvent(entity, action, newEntity)
            arguments
                entity      {mustBeA(entity, {'aod.core.Entity', 'aod.persistent.Entity'})}
                action      {mustBeMember(action, {'Add', 'Remove', 'Replace'})}
                newEntity   = []
            end
            
            obj.Entity = entity;
            obj.Action = action;
            
            if ~isempty(newEntity)
                mustBeA(newEntity, 'aod.persistent.Entity');
            end
            obj.NewEntity = newEntity;
        end
    end
end 