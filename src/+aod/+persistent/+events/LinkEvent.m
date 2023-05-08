classdef (ConstructOnLoad) LinkEvent < event.EventData
% Event involving an HDF5 softlink
%
% Description:
%   An event triggered when an HDF5 softlink is added/changed/removed
%
% Parent:
%   event.EventData
%
% Constructor:
%   obj = aod.persistent.events.LinkEvent(name, value)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties
        Name                char
        Value
        NewLink             logical 
    end

    methods
        function obj = LinkEvent(name, value, newLink)
            arguments
                name            char
                value           = []
                newLink         logical = false
            end

            obj.Name = name;
            obj.Value = value;
            obj.NewLink = newLink;
        end
    end
end