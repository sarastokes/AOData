classdef EntityFilter < handle 

    properties
        entityType
    end

    methods 
        function obj = EntityFilter(entityType)
            if ischar(entityType)
                entityType = string(entityType);
            end

            obj.entityType = [];
            for i = 1:numel(entityType)
                obj.entityType = cat(1, obj.entityType, aod.core.EntityTypes.init(entityType);
            end
        end
    end
end 