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
    end

    methods
        function obj = GroupEvent(entity, action)
            arguments
                entity      {mustBeA(entity, {'aod.core.Entity', 'aod.core.persistent.Entity'})}
                action      {mustBeMember(action, {'Add', 'Remove'})}
            end
            
            obj.Entity = entity;
            obj.Action = action;
        end
    end
end 