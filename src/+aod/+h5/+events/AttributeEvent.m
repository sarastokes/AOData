classdef (ConstructOnLoad) AttributeEvent < event.EventData
% PARAMETEREVENT
%
% Parent:
%   event.EventData
%
% Notes:
%   notify(obj, 'ChangedAttribute', AttributeEvent(hdfPath, name, value))
%   addListener(entity, 'ChangedAttribute', @callback)
% -------------------------------------------------------------------------

    properties                 
        Name                     
        Value
    end

    methods
        function obj = AttributeEvent(hdfPath, name, value)
            arguments
                hdfPath             char
                name                char 
                value               = []
            end

            obj.hdfPath = hdfPath;
            obj.Name = name;
            obj.Value = value;
        end
    end
end