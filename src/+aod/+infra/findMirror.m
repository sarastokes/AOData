function mirrorClass = findMirror(entityType, entityClass)
    % FINDMIRROR
    %
    % Description:
    %   Check if custom core class is mirrored in the persistent interface
    %
    % Syntax:
    %   mirrorClass = findMirror(entityType, entityClass)
    %
    % History:
    %   15Nov2022 - SSP
    % ---------------------------------------------------------------------
    
    arguments
        entityType
        entityClass
    end

    persistentClass = entityType.getPersistentClassName();

    % Default condition is that there is no mirror class
    mirrorClass = persistentClass;

    % Check for custom subclasses of default persistent class
    classRepo = aod.infra.ClassRepository();
    customClassNames = classRepo.get(persistentClass);
    if isempty(customClassNames)
        mirrorClass = persistentClass;
        return
    end

    mirroredClasses = erase(customClassNames, "persistent.");

    % Check whether class has persistent mirror
    idx = find(contains(mirroredClasses, entityClass));
    if ~isempty(idx)
        mirrorClass = customClassNames(idx);
        return
    end

    % Check whether superclasses have persistent mirror
    x = string(superclasses(entityClass));
    for i = 1:numel(x)
        idx = find(contains(mirroredClasses, x(i)));
        if ~isempty(idx)
            mirrorClass = idx;
            return
        end
    end
