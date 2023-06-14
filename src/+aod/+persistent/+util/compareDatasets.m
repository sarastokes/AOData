function [addList, removeList, changeList] = compareDatasets(oldObj, newObj)
% Compare datasets and return the changes
%
% Syntax:
%   [addList, removeList, changeList] = aod.persistent.util.compareDatasets(oldObj, newObj)
%
% Inputs:
%   oldObj          aod.persistent.Entity
%   newObj          aod.core.Entity

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    arguments
        oldObj      aod.persistent.Entity 
        newObj      aod.core.Entity 
    end
    
    oldProps = oldObj.dsetNames;
    newProps = aod.h5.getPersistedProperties(metaclass(newObj));

    if isempty(newProps) && isempty(oldProps)
        return
    elseif isempty(newProps) && ~isempty(oldProps)
        removeList = oldProps;
        return
    elseif ~isempty(newProps) && isempty(oldProps)
        addList = newProps;
        return 
    end

    removeList = setdiff(oldProps, newProps);
    addList = setdiff(newProps, oldProps);

    changeList = [];
    sharedList = intersect(oldProps, newProps);
    for i = 1:numel(sharedList)
        if ~isequal(oldObj.(sharedList(i)), newObj.(sharedList(i)))
            changeList = cat(1, changeList, sharedList(i));
        end
    end

    sharedList = setdiff(sharedList, ["Parent", "attributes", "files"]);
