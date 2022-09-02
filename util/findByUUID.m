function [entity, idx] = findByUUID(entities, uuid)
% FINDBYUUID
%
% Syntax:
%   [entity, idx] = findByUUID(entities, uuid)
%
% History:
%   09Aug2022 - SSP
%   02Sep2022 - SSP - Added catch for passing an empty array of entities
% -------------------------------------------------------------------------

    if isempty(entities)
        entity = [];
        idx = [];
        return
    end
    
    if iscell(entities)
        idx = false(1, numel(entities));
        for i = 1:numel(entities)
            if isSubclass(entities{i}, 'aod.core.Entity')
                idx(i) = isequal(entities{i}.UUID, uuid);
            end
        end
    else
        assert(isSubclass(entities, 'aod.core.Entity'));
        idx = vertcat(entities.UUID) == uuid;
    end

    idx = find(idx);
    if ~isempty(idx)
        if iscell(entities)
            entity = entities{idx};
        else
            entity = entities(idx);
        end
    else
        entity = [];
    end
