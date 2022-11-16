function isEntitySubclass(obj, entityType)
    % ISENTITYSUBCLASS
    %
    % Description:
    %   Check entity subclass identity (either core or persistent)
    %
    % Syntax:
    %   tf = isEntitySubclass(obj, entityType)
    %
    % Inputs:
    %   obj             object to check class 
    %   entityType      char/aod.core.EntityTypes (default = all entities)
    %
    % Examples:
    %   % Check whether class is an Entity subclass
    %   tf = isEntitySubclass(obj)
    %
    %   % Check whether class is a Segmentation subclass
    %   tf = isEntitySubclass(obj, "Segmentation")
    %
    % History:
    %   16Nov2022 - SSP
    % ---------------------------------------------------------------------
    if nargin < 2
        tf = isSubclass(obj, {'aod.core.Entity', 'aod.persistent.Entity'});
        return
    end

    entityType = aod.core.EntityTypes.init(entityType);
    persistentParentClass = entityType.getPersistentClassName();
    coreParentClass = entityType.getCoreClassName();

    tf = isSubclass(obj, {persistentParentClass, coreParentClass});
