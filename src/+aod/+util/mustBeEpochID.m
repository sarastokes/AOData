function mustBeEpochID(obj, epochIDs)
% mustBeEpochID
%
% Description:
%   Validation function for determining whether user-specified epochIDs
%   are present in the parent Experiment
%
% Syntax:
%   aod.util.mustBeEpochID(obj, epochIDs)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    arguments
        obj         {aod.util.mustBeEntity(obj)}
        epochIDs    {mustBeInteger(epochIDs)}
    end

    if any(~ismember(epochIDs, obj.epochIDs))
        eidType = "mustBeEpochID:UnmatchedID";
        msgType = "Specified epochIDs are not present in Experiment";
        throwAsCaller(MException(eidType, msgType));
    end
