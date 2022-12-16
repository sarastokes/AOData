classdef (ConstructOnLoad) FileEvent < event.EventData
% FILEEVENT
%
% Description:
%   An event triggered when an file is added/changed/removed
%
% Parent:
%   event.EventData
%
% Constructor:
%   obj = aod.persistent.events.FileEvent(name, value)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties
        Name 
        Value 
    end

    methods
        function obj = FileEvent(name, value)
            arguments
                name        char
                value       = []
            end

            obj.Name = name;
            obj.Value = value;
        end
    end
end 