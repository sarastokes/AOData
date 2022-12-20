function [entity, idx] = findByUUID(entities, uuid)
% Find a core entity by UUID
%
% Syntax:
%   [entity, idx] = findByUUID(entities, uuid)
%
% History:
%   09Aug2022 - SSP
%   02Sep2022 - SSP - Added catch for passing an empty array of entities
%   20Dec2022 - SSP - Removed outdated cell option for entity input
% -------------------------------------------------------------------------
    arguments 
        entities            {mustBeA(entities, 'aod.core.Entity')}
        uuid                string
    end 

    if isempty(entities)
        entity = [];
        idx = [];
        return
    end
    
    idx = vertcat(entities.UUID) == uuid;
    
    idx = find(idx);
    if ~isempty(idx)
        entity = entities(idx);
    else
        entity = [];
    end
