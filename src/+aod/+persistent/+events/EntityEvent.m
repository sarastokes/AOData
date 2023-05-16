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

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties
        Action 
        Entity 
        NewPath
    end

    methods
        function obj = EntityEvent(action, entity, hdfPath)
            arguments
                action          {mustBeMember(action, {'Add', 'Remove', 'Rename'})}
                entity          = []
                hdfPath         string = string.empty()
            end
            
            obj.Action = action;
            obj.Entity = entity;
            obj.NewPath = hdfPath;
        end
    end
end 