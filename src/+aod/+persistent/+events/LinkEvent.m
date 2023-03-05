classdef (ConstructOnLoad) LinkEvent < event.EventData
% LINKEVENT
%
% Description:
%   An event triggered when an HDF5 dataset is added/changed/removed
%
% Parent:
%   event.EventData
%
% Constructor:
%   obj = aod.persistent.events.LinkEvent(name, value)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties
        Name
        Value
    end

    methods
        function obj = LinkEvent(name, value)
            arguments
                name            char
                value           = []
            end

            obj.Name = name;
            obj.Value = value;
        end
    end
end