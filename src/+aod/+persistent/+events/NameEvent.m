classdef (ConstructOnLoad) NameEvent < event.EventData 
% Entity group name change event
%
% Description:
%   An event triggered when the name of an HDF5 group is changed
%
% Parent:
%   event.EventData
%
% Constructor:
%   obj = aod.persistent.events.NameEvent(entity, action, oldEntity)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties
        Name                string 
        OldName             string
    end

    methods
        function obj = NameEvent(name, oldName)
            arguments 
                name        string 
                oldName     string 
            end

            obj.Name = name;
            obj.OldName = oldName;
        end
    end
end