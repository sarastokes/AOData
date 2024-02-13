function fPath = navToRoot(className, target)
% NAVTOROOT  Navigate to root package folder
%
% Description:
%   Navigate to the root package folder that contains schemas.
%
% Syntax:
%   fPath = aod.schema.util.navToRoot(className)
%
% Inputs:
%   className           string
%       The name of the AOData class
%   targetFolder        string
%       Specify whether to root (default), "registry" or "json"
%
% Outputs:
%   fPath               string/char
%       The file path to the folder containing schemas
%
% Throws:
%   navToRoot:InvalidInput
%       When class name isn't on search path

% By Sara Patterson, 2024 (AOData)
% -------------------------------------------------------------------------

    arguments
        className   (1,1)   string
        target      (1,1)   string {mustBeMember(target, ["json", "registry", ""])} = ""
    end

    if ~exist(className, "class")
        error("navToRoot:InvalidInput", ...
            "Class %s not found on MATLAB path", className);
    end
    % TODO: Check for AOData subclass?

    fPath = which(className);

    while ~exist(fullfile(fPath, 'schemas'), 'dir')
        if isequal(fPath, fileparts(fPath)) || aod.util.isempty(fPath)
            fPath = [];
            return
        end
        fPath = fileparts(fPath);
    end

    if nargin == 1 || target == ""
        return
    end

    switch target
        case "registry"
            fPath = fullfile(fPath, "schemas", "registry.txt");
        case "json"
            txt = strsplit(className, ".");
            fPath = fullfile(fPath, "schemas", txt(1:end-1));
            fPath = fullfile(fPath, txt(end)+".json");
    end
