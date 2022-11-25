function checkEpochIDs(entity, epochIDs)
    % CHECKEPOCHIDS
    %
    % Description:
    %   Checks whether user-specified epochIDs are present in experiment
    %
    % Syntax:
    %   checkEpochIDs(entity, epochIDs)
    % ---------------------------------------------------------------------
    if entity.entityType ~= aod.core.EntityTypes.EXPERIMENT
        entity = entity.ancestor('Experiment');
        if isempty(entity)
            error("checkEpochIDs:NoExperiment",...
                "Entity has no parent Experiment");
        end
    end
    if any(~ismember(epochIDs, entity.epochIDs))
        error('checkEpochIDs:InvalidID',...
            'Input does not match Experiment epochIDs');
    end