function [classNames, pkgNames] = collectAllPackageClasses(pkgName, entityFlag)
% Collect all subpackage classnames
%
% Syntax:
%   classNames = aod.specification.util.collectAllPackageClasses(pkgName)
%
% Inputs:
%   pkgName         char or string
%       The package's name (e.g., "aod.builtin")

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    arguments 
        pkgName             string
        entityFlag          logical = true
    end

    classNames = string.empty(); pkgNames = string.empty();
    mp = meta.package.fromName(pkgName);
    [classNames, pkgNames] = processPackage(mp, classNames, pkgNames);

    % Extract only the entities

    if entityFlag
        idx = arrayfun(@(x) isSubclass(x, 'aod.core.Entity'), classNames);
        classNames = classNames(idx);

        idx = arrayfun(@(x) any(startsWith(classNames, x)), pkgNames);
        pkgNames = pkgNames(idx);
    end

    if ~ismember(pkgName, pkgNames)
        pkgNames = [pkgName; pkgNames];
    end
end

function [classNames, subPkgNames] = processPackage(mp, classNames, subPkgNames)
    classNames = cat(1, classNames, string({mp.ClassList.Name})');
    subPkgNames = [subPkgNames; string({mp.PackageList.Name})'];
    for i = 1:numel(mp.PackageList)
        [classNames, subPkgNames] = processPackage(...
            mp.PackageList(i), classNames, subPkgNames);
    end
end


