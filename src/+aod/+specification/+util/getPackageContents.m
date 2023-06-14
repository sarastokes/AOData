function classes = getPackageContents(pkgName, entityFlag)
% Get the classes and subpackages for a specific package
%
% Syntax:
%   [classes, pkgs] = aod.specification.util.getPackageContents(pkgName, entityFlag)
%
% Inputs:
%   pkgName             string
%       The package's name
%   entityFlag          logical
%       Whether to only return core entities (default = true)
%
% Outputs:
%   classes             string
%       An array of class names

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    if nargin < 2
        entityFlag = true;
    end

    mp = meta.package.fromName(pkgName);
    classes = string({mp.ClassList.Name})';

    if entityFlag
        idx = arrayfun(@(x) isSubclass(x, 'aod.core.Entity'), classes);
        classes = classes(idx);
    end