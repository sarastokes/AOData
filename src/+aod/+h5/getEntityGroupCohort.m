function groupNames = getEntityGroupCohort(entity)
% Get other group names within entity's container
%
% Syntax:
%   groupName = aod.h5.getEntityGroupCohort(entity)
%
% Inputs:
%   entity              aod.persistent.Entity subclass
%
% See also:
%   h5tools.collectGroups

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    arguments
        entity          aod.persistent.Entity 
    end

    hdfName = entity.hdfName;
    entityContainerPath = h5tools.util.getPathParent(entity.hdfPath);

    allGroupNames = h5tools.collectGroups(hdfName, true);
    childNames = allGroupNames(startsWith(allGroupNames, entityContainerPath));

    parentOrder = h5tools.util.getPathOrder(entityContainerPath);
    cohortNames = childNames(h5tools.util.getPathOrder(childNames) == parentOrder + 1);
    
    groupNames = string.empty();
    for i = 1:numel(cohortNames)
        groupNames = cat(1, groupNames,... 
            string(h5tools.util.getPathEnd(cohortNames(i))));
    end
