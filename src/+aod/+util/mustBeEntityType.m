function mustBeEntity(obj, entityType)
    % MUSTBEENTITY
    %
    % Description:
    %   Argument validation function to determine whether input is a 
    %   specific entity type (either core or persistent interface)
    %
    % Syntax:
    %   mustBeEntityTy[e(obj, entityType)
    %
    % Inputs:
    %   obj             AOData object
    %   entityType      aod.core.EntityTypes or char/string of entityType
    %
    % Examples:
    %   mustBeEntityType(obj, aod.core.EntityTypes.SEGMENTATION)
    %   mustBeEntityType(obj, 'segmentation');
    % ---------------------------------------------------------------------

    entityType = aod.core.EntityTypes.init(entityType);

    if ~isscalar(obj)
        for i = 1:numel(obj)
            mustBeEntityType(obj, entityType);
        end
    end

    if ~isSubclass(obj, entityType.getCoreClassName()) ...
            && ~isSubclass(obj, entityType.getPersistentClassName())
        eidType = 'mustBeEntityType:EntityTypeDoesNotMatch';
        msgType = sprintf('Entity must be %s', char(entityType));
        throwAsCaller(MException(eidType, msgType));
    end