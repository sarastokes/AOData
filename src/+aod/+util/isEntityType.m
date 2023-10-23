function tf = isEntityType(obj, entityType)
% Determine whether entity is of a specific type
%
% Description:
%   Determine whether object is a specific entity type
%
% Syntax:
%   tf = aod.util.isEntityType(obj, entityType)
%
% Inputs:
%   obj             AOData object
%   entityType      aod.common.EntityTypes or char/string of entityType
%       One or more entity types

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    entityType = convertCharsToStrings(entityType);

    if ~isscalar(obj)
        for i = 1:numel(obj)
            aod.util.mustBeEntityType(obj(i), entityType);
        end
    end


    for i = 1:numel(entityType)
        iType = aod.common.EntityTypes.get(entityType(i));
        if isSubclass(obj, iType.getCoreClassName()) || ...
            isSubclass(obj, iType.getPersistentClassName())
            tf = true;
            return
        end
    end

    tf = false;