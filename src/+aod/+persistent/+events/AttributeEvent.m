classdef (ConstructOnLoad) AttributeEvent < event.EventData
% ATTRIBUTEEVENT
%
% Description:
%   An event triggered when an HDF5 dataset is added/changed/removed
%
% Parent:
%   event.EventData
%
% Notes:
%   notify(obj, 'ChangedAttribute', AttributeEvent(hdfPath, name, value))
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