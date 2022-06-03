function tf = isEntity(obj)
    % ISENTITY
    %
    % Description:
    %   tf = aod.util.validators.isEntity(obj)
    %
    % See also:
    %   aod.core.Entity
    % ---------------------------------------------------------------------
    tf = ismember('aod.core.Entity', superclasses(obj));