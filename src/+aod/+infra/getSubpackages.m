function [subpackageNames, classNames] = getSubpackages(basePkg)
% GETSUBPACKAGES
%
% Description:
%   Returns a list of all packages and classe swithin a given package
%
% Syntax:
%   [subpackageNames, classNames] = getSubpackages(basePkg)
%
% Example:
%   [subpackageNames, classNames] = getSubpackages('aod.builtin')

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    mp = meta.package.fromName(basePkg);

    subpackageNames = arrayfun(@(x) string(x.Name), mp.PackageList);
    classNames = arrayfun(@(x) string(x.Name), mp.ClassList);

    for i = 1:length(subpackageNames)
        [subpackageNames, classNames] = parseSubpackage(...
            mp.PackageList(i), subpackageNames, classNames);
    end
end

function [pkgNames, classNames] = parseSubpackage(mp, pkgNames, classNames)
% Called recursively until no more subpackages are found
    classNames = [classNames; arrayfun(@(x) string(x.Name), mp.ClassList)];
    iPkgNames = arrayfun(@(x) string(x.Name), mp.PackageList);
    if ~isempty(iPkgNames)
        pkgNames = [pkgNames; iPkgNames];
        for i = 1:numel(mp.PackageList)
            [pkgNames, classNames] = parseSubpackage(...
                mp.PackageList(i), pkgNames, classNames);
        end
    end
end