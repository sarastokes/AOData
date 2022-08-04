function classNames = getClassWithoutPackages(obj)
    % GETCLASSWITHOUTPACKAGES
    %
    % Description:
    %   Returns classname(s) without packages
    %
    % Syntax:
    %   out = getClassWithoutPackages(obj)
    %
    % History:
    %   03Aug2022 - SSP
    % ---------------------------------------------------------------------

    classNames = string.empty();
    for i = 1:numel(obj)
        fullName = class(obj(i));
        allNames = strsplit(fullName, '.');
        classNames = cat(1, classNames, string(allNames{end}));
    end
