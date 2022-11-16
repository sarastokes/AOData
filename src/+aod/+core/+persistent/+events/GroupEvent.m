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
%   obj = GroupEvent(entity)
% ------------------------------------------------------------------------

    properties
        Entity
        Action
        OldEntity
    end

    methods
        function obj = GroupEvent(entity, action, oldEntity)
            arguments
                entity      {mustBeA(entity, {'aod.core.Entity', 'aod.core.persistent.Entity'})}
                action      {mustBeMember(action, {'Add', 'Remove', 'Replace'})}
                oldEntity   {mustBeA(oldEntity, 'aod.core.persistent.Entity')} = []
            end
            
            obj.Entity = entity;
            obj.Action = action;
            obj.OldEntity = oldEntity;
        end
    end
end 