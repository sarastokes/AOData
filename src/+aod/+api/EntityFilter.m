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
    end

    methods
        
        function out = describe(obj)
            tag = sprintf("ParameterFilter: Name=%s, Value=%s",... 
                value2string(obj.Name), value2string(obj.Value));
        end
        
        function out = apply(obj)
            obj.localIdx = obj.getQueryIdx();
            groupNames = obj.getAllGroupNames();
            hdfFiles = obj.getFileNames();
            fileIdx = obj.getFileIdx();
        
            for i = 1:numel(groupNames)
                if obj.localIdx(i)
                    entityType = h5readatt(hdfFiles(fileIdx(i)),...
                        groupNames(i), 'EntityType');
                    obj.localIdx(i) = strcmpi(entityType, obj.EntityName);
                end
            end

            if nnz(obj.localIdx) == 0
                warning('apply:NoMatches',...
                    'No matches for entity type %s', obj.EntityName);
            end
            
            out = obj.localIdx;
        end
    end
end 