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
%   obj = LinkEvent(name, value)
% ------------------------------------------------------------------------

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
            obj.Value = value
        end
    end
end