function mustHaveParent(obj)
% Validate entity has parent
%
% Description:
%   Argument validation function to determine whether entity has parent
%
% Syntax:
%   aod.util.mustHaveParent(obj, entityType)
%
% Inputs:
%   obj             AOData object
%
% Examples:
%   aod.util.mustHaveParent(obj)
% 
% See also:
%   aod.util.mustBeEntity

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    aod.util.mustBeEntity(obj);

    if isempty(obj.Parent)
        eidType = 'mustHaveParent:NoParent';
        msgType = sprintf('Entity %u does not have parent', obj.groupName);
        throwAsCaller(MException(eidType, msgType));
    end
    