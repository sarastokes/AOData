function mustNotBeSystemAttribute(name)
    % MUSTNOTBESYSTEMATTRIBUTE
    %
    % Description:
    %   Argument validation function to determine whether input is 
    %   reserved by AOData
    %
    % Syntax:
    %   mustNotBeSystemAttribute(name)
    %
    % ---------------------------------------------------------------------

    arguments
        name            string
    end

    if ismember(name, aod.h5.getSystemAttributes())
        eidType = "mustNotBeSystemAttribute:InvalidInput";
        msgType = sprintf('%s is reserved by AOData and cannot be directly modified');
        throwAsCaller(MException(eidType, msgType));
    end