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
    %   entityType      aod.common.EntityTypes or char/string of entityType
    %       One or more entity types
    %
    % Examples:
    %   aod.util.mustBeEntityType(obj, aod.common.EntityTypes.ANNOTATION)
    %   aod.util.mustBeEntityType(obj, 'annotation');
    
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
                return
            end
        end
    
        eidType = 'mustBeEntityType:InvalidEntityType';
        msgType = sprintf('Entity must be %s', array2commalist(entityType));
        throwAsCaller(MException(eidType, msgType));
    