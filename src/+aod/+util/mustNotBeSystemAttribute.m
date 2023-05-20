function mustNotBeSystemAttribute(name)
% Validate argument is not a system attribute
%
% Description:
%   Argument validation function to determine whether input is 
%   reserved by AOData
%
% Syntax:
%   aod.util.mustNotBeSystemAttribute(name)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    arguments
        name            string
    end

    if ismember(name, aod.infra.getSystemAttributes())
        eidType = "mustNotBeSystemAttribute:InvalidInput";
        msgType = sprintf('%s is reserved by AOData and cannot be directly modified', name);
        throwAsCaller(MException(eidType, msgType));
    end