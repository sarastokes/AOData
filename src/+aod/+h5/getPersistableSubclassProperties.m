function propNames = getPersistableSubclassProperties(obj)


    [persistedProps, ~, ~, emptyProps] = aod.h5.getPersistedProperties(obj);
    propNames = cat(1, persistedProps, emptyProps);
    propNames = setdiff(propNames, aod.infra.getSystemProperties());