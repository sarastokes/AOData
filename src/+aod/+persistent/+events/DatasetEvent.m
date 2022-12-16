classdef (ConstructOnLoad) DatasetEvent < event.EventData 
% DATASETEVENT
%
% Description:
%   An event triggered when an HDF5 dataset is added/changed/removed
%
% Parent:
%   event.EventData
%
% Constructor:
%   obj = DatasetEvent(name, newValue, oldValue)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------
    
    properties
        Name
        NewValue
        OldValue
    end

    methods
        function obj = DatasetEvent(name, newValue, oldValue)
            arguments
                name            char
                newValue        = []   
                oldValue        = []
            end

            obj.Name = name;
            obj.NewValue = newValue;
            obj.OldValue = oldValue;
        end
    end
end