function [pkgName, className] = splitClassName(fullName)
% SPLITCLASSNAME
%
% Description:
%   Splits class name into filename and package name
%
% Syntax:
%   [pkgName, className] = splitClassName(fullName);
%
% Examples:
%   % Returns ["aod.core" and "Calibration"]
%   [pkgName, className] = splitClassName("aod.core.Calibration")

% By Sara Patterson, 2024 (AOData)
% -------------------------------------------------------------------------

    arguments
        fullName           string
    end

    if ~isscalar(fullName)
        [pkgName, className] = arrayfun(@(x) splitClassName(x), fullName);
        return
    end

    if ~contains(fullName, ".")
        pkgName = [];
        className = fullName;
        return
    end

    txt = strsplit(fullName, ".");
    className = txt(end);
    pkgName = strjoin(txt(1:end-1), ".");