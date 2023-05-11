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
%   entityType      string or aod.core.EntityTypes
%       Entities to search 
%
% Examples:
%   QM = aod.api.EntityManager("MyFile.h5")
%   % Initialize by entity name
%   EF1 = aod.api.EntityFilter(QM, 'Response')
%   % Initialize by entity type
%   EF2 = aod.api.EntityFilter(QM, aod.core.EntityTypes.RESPONSE)
%   % Search for more than one entity
%   EF3 = aod.api.EntityFilter(QM, ["Experiment", "Epoch"]);
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

            entityType = convertCharsToStrings(entityType);
            obj.EntityName = arrayfun(...
                @(x) string(aod.core.EntityTypes.get(x)), entityType);
        end
    end

    methods
        
        function tag = describe(obj)
            tag = sprintf("EntityFilter: Type=%s", char(obj.EntityName));
        end

        function out = apply(obj)
            obj.localIdx = obj.getQueryIdx();
            entities = obj.getEntityTable();
        
            for i = 1:height(entities)
                if obj.localIdx(i)
                    obj.localIdx(i) = ismember(entities.Entity(i), obj.EntityName);
                end
            end

            if nnz(obj.localIdx) == 0
                warning('apply:NoMatches',...
                    'No matches for entity type %s', obj.EntityName);
            end
            
            out = obj.localIdx;
        end

        function txt = code(obj, input, output)
            arguments 
                obj 
                input           string  = "QM"
                output          string  = []
            end

            txt = sprintf("aod.api.EntityFilter(%s, %s)",... 
                input, value2string(obj.EntityName));
            if ~isempty(output)
                txt = sprintf("%s = %s;", output, txt);
            end
        end        
    end
end 