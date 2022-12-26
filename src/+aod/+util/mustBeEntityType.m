function mustBeEntityType(obj, entityType)
% Validate entity is of a specific type
%
% Description:
%   Argument validation function to determine whether input is a 
%   specific entity type (either core or persistent interface)
%
% Syntax:
%   aod.util.mustBeEntityType(obj, entityType)
%
% Inputs:
%   obj             AOData object
%   entityType      aod.core.EntityTypes or char/string of entityType
%
% Examples:
%   aod.util.mustBeEntityType(obj, aod.core.EntityTypes.ANNOTATION)
%   aod.util.mustBeEntityType(obj, 'annotation');

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    entityType = aod.core.EntityTypes.get(entityType);

    if ~isscalar(obj)
        for i = 1:numel(obj)
            aod.util.mustBeEntityType(obj(i), entityType);
        end
    end

    if ~isSubclass(obj, entityType.getCoreClassName()) ...
            && ~isSubclass(obj, entityType.getPersistentClassName())
        eidType = 'mustBeEntityType:InvalidEntityType';
        msgType = sprintf('Entity must be %s', char(entityType));
        throwAsCaller(MException(eidType, msgType));
    end