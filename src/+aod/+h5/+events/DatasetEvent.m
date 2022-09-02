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
% ------------------------------------------------------------------------
    
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
            obj.NewValue = value;
            obj.OldValue = value;
        end
    end
end