function [classNames, subPkgNames] = collectAllPackageClasses(pkgName)
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

    classNames = string.empty(); subPkgNames = string.empty();
    mp = meta.package.fromName(pkgName);
    [classNames, subPkgNames] = processPackage(mp, classNames, subPkgNames);
end

function [classNames, subPkgNames] = processPackage(mp, classNames, subPkgNames)
    classNames = cat(1, classNames, string({mp.ClassList.Name})');
    subPkgNames = [subPkgNames; string({mp.PackageList.Name})'];
    for i = 1:numel(mp.PackageList)
        classNames = processPackage(...
            mp.PackageList(i), classNames, subPkgNames);
    end
end


