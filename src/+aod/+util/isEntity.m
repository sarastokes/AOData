function [tf, persisted] = isEntity(entity)
    % ISENTITY
    %
    % Description:
    %   Returns whether input is an AOData entity and if so, whether the
    %   entity is persisted or not
    %
    % Syntax:
    %   [tf, persisted] = isEntity(entity)
    % ---------------------------------------------------------------------
    if isSubclass(entity, 'aod.core.persistent.Entity')
        tf = true;
        persisted = true;
    elseif isSubclass(entity, 'aod.core.Entity')
        tf = true;
        persisted = false;
    else
        tf = false;
        persisted = [];
    end
