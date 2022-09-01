function checkAllEntityNames(obj)

    checkGroupNames(obj.Calibrations)
    checkGroupNames(obj.Regions);
    checkGroupNames(obj.Analyses);
    checkGroupNames(obj.Epochs);
    checkGroupNames(obj.Systems);
    checkGroupNames(obj.Sources);
    
    if ~isempty(obj.Systems)
        for i = 1:numel(obj.Systems)
            checkGroupNames(obj.Systems(i).Channels);
            if ~isempty(obj.Systems(i).Channels)
                for j = 1:numel(obj.Systems(i).Channels(j))
                    checkGroupNames(obj.Systems(i).Channels(j).Devices);
                end
            end
        end
    end

    if ~isempty(obj.Epochs)
        for i = 1:numel(obj.Epochs)
            checkGroupNames(obj.Epochs(i).Datasets);
            checkGroupNames(obj.Epochs(i).Registrations);
            checkGroupNames(obj.Epochs(i).Responses);
            checkGroupNames(obj.Epochs(i).Stimuli);
        end
    end
end

function checkGroupNames(entities)
    if isempty(entities)
        return
    end
    import aod.core.EntityTypes

    allNames = arrayfun(@(x) EntityTypes.getGroupName(x), entities,...
        'UniformOutput', false);
    [G, groupNames] = findgroups(allNames);
    N = splitapply(@numel, allNames, G);

    if max(N) == 1
        return
    end

    for i = 1:numel(N)
        if N(i) > 1
            warning('%s contains %s conflict! Name = %s',...
                EntityTypes.getGroupName(entities(1)),...
                char(EntityTypes.get(entities(1))),...
                groupNames(i));
        end
    end
end