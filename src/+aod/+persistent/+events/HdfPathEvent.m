classdef (ConstructOnLoad) HdfPathEvent < event.EventData 

    properties 
        Entity
        NewPath 
        OldPath 
    end

    methods 
        function obj = HdfPathEvent(entity, oldPath, newPath)
            obj.Entity = entity;
            obj.OldPath = oldPath;
            obj.NewPath = newPath;
        end
    end
end 