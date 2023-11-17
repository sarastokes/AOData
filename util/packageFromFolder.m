function [pkgName, mp] = packageFromFolder(filePath)
% PACKAGEFROMFOLDER
%
% Description:
%   Returns package name and optionally meta.package from folder path
%
% Syntax:
%   [pkgName, mp] = packageFromFolder(filePath)
%
% Inputs:
%   filePath        char/string
%       Path to folder
%
% Outputs:
%   pkgName         string
%   mp              meta.package

% By Sara Patterson, 2023 (AOData)
% ----------------------------------------------------------------------

    arguments
        filePath        (1,1)       string      {mustBeFolder}
    end

    txt = string(strsplit(filePath, filesep));
    txt = txt(arrayfun(@(x) startsWith(x, "+"), txt));
    if isempty(txt)
        error('Namespace:InvalidPackage',...
            'No package folders beginning with + were identified');
    end
    pkgName = erase(strjoin(txt, "."), "+");
    try
        mp = meta.package.fromName(pkgName);
    catch
        error('Namespace:InvalidPackage', 'Invalid package name %s', pkgName);
    end