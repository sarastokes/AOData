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
%   obj = aod.api.EntityFilter(parent, entityType)
%
% Inputs:
%   parent          aod.api.QueryManager
%   entityType      text name of entity or aod.core.EntityTypes
%
% Examples:
%   QM = aod.api.EntityManager("MyFile.h5")
%   % Initialize by entity name
%   EF1 = aod.api.FilterQuery(QM, 'Response')
%   % Initialize by entity type
%   EF2 = aod.api.FilterQuery(QM, aod.core.EntityTypes.RESPONSE)
%
% See also:
%   aod.api.QueryManager

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        EntityName          
    end

    methods 
        function obj = EntityFilter(parent, entityType)
            obj@aod.api.FilterQuery(parent);
            obj.EntityName = char(aod.core.EntityTypes.get(entityType));
        end

        function out = apply(obj)
            % Update local match indices to match those in Query Manager
            obj.localIdx = obj.Parent.filterIdx;
        
            for i = 1:numel(obj.Parent.allGroupNames)
                if obj.localIdx(i)
                    hdfFile = obj.Parent.getHdfName(i);
                    entityType = h5readatt(hdfFile,...
                        obj.Parent.allGroupNames(i), 'EntityType');
                    obj.localIdx(i) = strcmpi(entityType, obj.EntityName);
                end
            end

            if nnz(obj.localIdx)
                warning('apply:NoMatches',...
                    'No matches for entity type %s', obj.EntityName);
            end
            
            out = obj.localIdx;
        end
    end
end 