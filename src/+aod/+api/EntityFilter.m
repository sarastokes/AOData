classdef EntityFilter < aod.api.FilterQuery
% ENTITYFILTER
%
% Description:
%   Filter entities in an AOData HDF5 file by entity type
%
% Parent:
%   aod.api.FilterQuery
%
% Constructor:
%   obj = EntityFilter(hdfName, entityName)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        entityName 
    end

    methods 
        function obj = EntityFilter(hdfName, entityName)
            entityName = char(aod.core.EntityTypes.init(entityName));
            obj@aod.api.FilterQuery(hdfName);
            obj.entityName = entityName;
            obj.applyFilter();
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
