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

    if ~isscalar(obj)
        for i = 1:numel(obj)
            mustBeEntity(obj, entityType);
        end
    end

    if ~isSubclass(obj, {'aod.core.Entity', 'aod.persistent.Entity'})
        eidType = 'mustBeEntity:InputIsNotAODataEntity';
        msgType = 'Input must be subclass of aod.core.Entity or aod.persistent.Entity';
        throwAsCaller(MException(eidType, msgType));
    end