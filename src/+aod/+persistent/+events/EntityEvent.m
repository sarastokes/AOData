classdef (ConstructOnLoad) EntityEvent < event.EventData
% An event occurring when an entity changes in a persisted experiment
%
% Description:
%   An event triggered when an entity is added, removed or replaced.
%
% Parent:
%   event.EventData
%
% Constructor:
%   obj = aod.persistent.events.EntityEvent(action, oldUUID)
%
% Inputs:
%   action          char
%       'Add', 'Remove', or 'Replace'
%   oldUUID         string (default = "")
%       UUID of existing persisted entity involved in change

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties
        UUID
        Action 
    end

    methods
        function obj = EntityEvent(action, oldUUID)
            arguments
                action          {mustBeMember(action, {'Add', 'Remove'})}
                oldUUID         string = string.empty()
            end
            
            obj.Action = action;
            obj.UUID = oldUUID;
        end
    end
end 