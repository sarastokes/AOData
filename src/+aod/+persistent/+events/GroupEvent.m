classdef (ConstructOnLoad) GroupEvent < event.EventData
% GROUPEVENT
%
% Description:
%   An event triggered when an HDF5 group is added/changed/removed
%
% Parent:
%   event.EventData
%
% Constructor:
%   obj = aod.persistent.events.GroupEvent(entity, action, oldEntity)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties
        Entity
        Action
        OldEntity
    end

    methods
        function obj = GroupEvent(entity, action, oldEntity)
            arguments
                entity      {mustBeA(entity, {'aod.core.Entity', 'aod.persistent.Entity'})}
                action      {mustBeMember(action, {'Add', 'Remove', 'Replace'})}
                oldEntity    = []
            end
            
            obj.Entity = entity;
            obj.Action = action;
            if ~isempty(oldEntity)
                mustBeA(entity, 'aod.persistent.Entity');
            end
            obj.OldEntity = oldEntity;
        end
    end
end 