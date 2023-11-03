function className = getClassWithoutPackages(obj)
% GETCLASSWITHOUTPACKAGES
%
% Description:
%   Returns classname(s) without packages
%
% Syntax:
%   className = getClassWithoutPackages(obj)
%
% Inputs:
%   obj             object or string
%       Class name or instance of class
%
% History:
%   03Aug2022 - SSP
%   31Oct2023 - SSP - Better non-scalar support, class text input
% --------------------------------------------------------------------------

    obj = convertCharsToStrings(obj);

    % if ~isscalar(obj)
    %     className = arrayfun(@(x) getClassWithoutPackages(x), obj);
    %     return
    % end

    if isstring(obj)
        fullName = obj;
    else
        fullName = string(class(obj));
    end
    allNames = strsplit(fullName, '.');
    className = allNames(end);
