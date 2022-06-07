function mustBeSubclass(a, className)
% MUSTBESUBCLASS
%
% Description:
%   Property validation function 
%
% History:
%   06Jun2022 - SSP
% -------------------------------------------------------------------------
    if ~isSubclass(a, className)
        eidType = "MustBeSubclass:notSubclass";
        msgType = "Assigned values are not the correct subclass";
        throwAsCaller(MException(eidType, msgType));
    end
end