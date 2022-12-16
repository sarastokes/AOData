function mirrorClass = findMirror(entityType, entityClass, classManager)
% Search for a core class mirror in the persistent interface
%
% Description:
%   Determines how core class is mirrored in the persistent interface
%
% Syntax:
%   mirrorClass = findMirror(entityType, entityClass)
%   mirrorClass = findMirror(entityType, entityClass, repositoryManager)
%
% Notes:
%   Instantiating ClassRepository is time-consuming (179 ms per call)  
%   so if calling findMirror repeatedly, provide classRepository

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------
    
    
    arguments
        entityType      {mustBeA(entityType, 'aod.core.EntityTypes')}
        entityClass     string 
        classManager    {mustBeA(classManager, 'aod.infra.ClassRepository')} = []
    end

    if isempty(classManager)
        classManager = aod.infra.ClassRepository();
    end
    
    persistentClass = entityType.getPersistentClassName();

    % Default condition is that there is no mirror class
    mirrorClass = persistentClass;

    % Check for custom subclasses of default persistent class
    customClassNames = classManager.get(persistentClass);
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
            mirrorClass = customClassNames(idx);
            return
        end
    end
