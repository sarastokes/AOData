function mustBeEntity(obj, entityType)
    % MUSTBEENTITY
    %
    % Description:
    %   Argument validation function to determine whether input is a 
    %   specific entity type (either core or persistent interface)
    %
    % Syntax:
    %   mustBeEntity(obj, entityType)
    %
    % Inputs:
    %   obj             AOData object
    %   entityType      aod.core.EntityTypes or char/string of entityType
    %
    % Examples:
    %   mustBeEntity(obj, aod.core.EntityTypes.SEGMENTATION)
    %   mustBeEntity(obj, 'segmentation');
    % ---------------------------------------------------------------------

    entityType = aod.h5.EntityTypes.init(entityType);

    if ~isscalar(obj)
        for i = 1:numel(obj)
            mustBeEntity(obj, entityType);
        end
    end

    if ~isSubclass(obj, entityType.getCoreClassName()) ...
            && ~isSubclass(obj, entityType.getPersistentClassName())
        eidType = 'mustBeEntity:EntityTypeDoesNotMatch';
        msgType = sprintf('Entity must be %s', char(entityType));
        throwAsCaller(MException(eidType, msgType));
    end