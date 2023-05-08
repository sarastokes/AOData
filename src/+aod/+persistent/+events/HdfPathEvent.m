classdef (ConstructOnLoad) HdfPathEvent < event.EventData 
% An event for HDF5 path changes
%
% Description:
%   An event triggered when an HDF5 path is changed
%
% Parent:
%   event.EventData
%
% Constructor:
%   obj = aod.persistent.events.LinkEvent(name, value)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties 
        Entity          aod.persistent.Entity 
        NewPath         string 
        OldPath         string
    end

    methods 
        function obj = HdfPathEvent(entity, oldPath, newPath)
            obj.Entity = entity;
            obj.OldPath = oldPath;
            obj.NewPath = newPath;
        end
    end
end 