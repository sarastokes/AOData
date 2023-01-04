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
%
% See also:
%   aod.api.QueryManager

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        entityName          
    end

    methods 
        function obj = EntityFilter(parent, entityType)
            obj@aod.api.FilterQuery(parent);
            obj.entityName = char(aod.core.EntityTypes.get(entityType));
        end

        function out = apply(obj)
            % Update local match indices to match those in Query Manager
            obj.localIdx = obj.Parent.filterIdx;
        
            for i = 1:numel(obj.Parent.allGroupNames)
                if obj.localIdx(i)
                    hdfFile = obj.Parent.getHdfName(i);
                    entityType = h5readatt(hdfFile,...
                        obj.Parent.allGroupNames(i), 'EntityType');
                    obj.localIdx(i) = strcmpi(entityType, obj.entityName);
                end
            end
            
            out = obj.localIdx;
        end
    end
end 