classdef (ConstructOnLoad) AttributeEvent < event.EventData
% An event triggered by a change to data reflecting an HDF5 attribute
%
% Description:
%   An event triggered when an HDF5 dataset is added/changed/removed
%
% Parent:
%   event.EventData
%
% Constructor:
%   obj = aod.persistent.events.AttributeEvent(name, value)
%
% Inputs:
%   name        char
%       Attribute name 
%   value       (default = empty)
%       Attribute value. If empty, attribute is removed
%
% Examples:
%   notify(obj, 'ChangedAttribute', AttributeEvent(name, value))
%   addListener(entity, 'ChangedAttribute', @callback)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties                 
        Name                     
        Value
    end

    methods
        function obj = AttributeEvent(name, value)
            arguments
                name                char 
                value               = []
            end

            obj.Name = name;
            obj.Value = value;
        end
    end
end