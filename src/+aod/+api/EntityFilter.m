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
%   obj = aod.api.EntityFilter(hdfName, entityName)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        entityName 
    end

    methods 
        function obj = EntityFilter(hdfName, entityName)
            entityName = char(aod.core.EntityTypes.get(entityName));
            obj@aod.api.FilterQuery(hdfName);
            obj.entityName = entityName;
            obj.apply();
        end
    end

    % Implementation of FilterQuery abstract methods
    methods
        function apply(obj)
            obj.resetFilterIdx();
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
