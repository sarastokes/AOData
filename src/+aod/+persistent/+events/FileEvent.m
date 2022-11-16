classdef (ConstructOnLoad) FileEvent < event.EventData
% FILEEVENT
%
% Description:
%   An event triggered when an file is added/changed/removed
%
% Parent:
%   event.EventData
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