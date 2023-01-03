function out = getEnumMembers(enumClass)
% Get the members of an enumeration class
%
% Syntax:
%   out = getEnumMembers(enumClass)
%
% Inputs:
%   enumClass       enum class instance or name (char/string)
%
% Outputs:
%   out             string array
%       Members of the class

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    if istext(enumClass)
        mc = meta.class.fromName(enumClass);
    else
        mc = metaclass(enumClass);
    end
    out = arrayfun(@(x) string(x.Name), mc.EnumerationMemberList);