function groupNames = getEntityGroupCohort(entity)

    arguments
        entity          aod.persistent.Entity 
    end

    hdfName = entity.hdfName;
    entityContainerPath = h5tools.util.getPathParent(entity.hdfPath);

    allGroupNames = h5tools.collectGroups(hdfName, true);
    childNames = allGroupNames(startsWith(allGroupNames, entityContainerPath));

    parentOrder = h5tools.util.getPathOrder(entityContainerPath);
    cohortNames = childNames(h5tools.util.getPathOrder(childNames) == parentOrder + 1);
    groupNames = h5tools.util.getPathEnd(cohortNames);
