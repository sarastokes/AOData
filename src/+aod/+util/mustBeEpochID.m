function mustBeEpochID(obj, epochIDs)
    % mustBeEpochID
    %
    % Description:
    %   Validation function for determining whether user-specified epochIDs
    %   are present in the parent Experiment
    %
    % Syntax:
    %   mustBeEpochID(obj, epochIDs)
    % ---------------------------------------------------------------------

    arguments
        obj         {aod.util.mustBeEntity(obj)}
        epochIDs    {mustBeInteger(epochIDs)}
    end

    if any(~ismember(epochIDs, obj.epochIDs))
        eidType = "mustBeEpochID:UnmatchedID";
        msgType = "Specified epochIDs are not present in Experiment";
        throwAsCaller(MException(eidType, msgType));
    end