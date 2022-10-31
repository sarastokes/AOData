classdef EntityFilter < aod.api.FilterQuery

    properties (SetAccess = private)
        entityName 
    end

    methods 
        function obj = EntityFilter(hdfName, entityName)
            assert(ismember(string(entityName), enumStr('aod.core.EntityTypes')));
            obj@aod.api.FilterQuery(hdfName);
        end

        function applyFilter(obj)
            % Select groups that match the entity
            for i = 1:numel(obj.allGroupNames)
                if obj.filterIdx(i)
                    entityType = h5readatt(obj.hdfName,...
                        obj.allGroupNames(i), 'EntityType');
                    obj.filterIdx(i) = strcmpi(entityType, obj.entityName);
                end
            end
        end
    end
end 
