function tf = isEntitySubclass(obj, entityType)
% Determine whether input is a valid entity or entityType
%
% Description:
%   Check entity subclass identity (either core or persistent). With one 
%   input, returns whether an Entity. With two inputs, returns whether it's 
%   an entity and of a specific entityType
%
% Syntax:
%   tf = aod.util.isEntitySubclass(obj, entityType)
%
% Inputs:
%   obj             object to check class 
%   entityType      char/aod.core.EntityTypes (default = all entities)
%
% Examples:
%   % Check whether class is an Entity subclass
%   tf = aod.util.isEntitySubclass(obj)
%
%   % Check whether class is a Annotation subclass
%   tf = aod.util.isEntitySubclass(obj, "Annotation")
%
% See also:
%   aod.core.EntityTypes

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    if nargin < 2
        tf = isSubclass(obj, {'aod.core.Entity', 'aod.persistent.Entity'});
        return
    end

    entityType = aod.core.EntityTypes.get(entityType);
    persistentParentClass = entityType.getPersistentClassName();
    coreParentClass = entityType.getCoreClassName();

    tf = isSubclass(obj, {persistentParentClass, coreParentClass});
