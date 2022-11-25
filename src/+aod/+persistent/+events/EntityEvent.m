classdef (ConstructOnLoad) EntityEvent < event.EventData
% ENTITYEVENT
%
% Description:
%   An event triggered by a specific entity
%
% Parent:
%   event.EventData
%
% Constructor:
%   obj = EntityEvent(uuid)
% -------------------------------------------------------------------------

    properties
        UUID
        Action 
    end

    methods
        function obj = EntityEvent(uuid, action)
            arguments
                uuid
                action          {mustBeMember(action, {'Add', 'Remove'})}
            end
            
            uuid = aod.util.validateUUID(uuid);
            obj.UUID = uuid;
            obj.Action = action;
        end
    end
end 