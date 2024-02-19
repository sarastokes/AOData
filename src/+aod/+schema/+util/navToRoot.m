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
%       Specify whether to root (default), "registry" or "schema"
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
        target      (1,1)   string {mustBeMember(target, ["schema", "registry", ""])} = ""
    end

    if ~exist(className, "class")
        error("navToRoot:InvalidInput", ...
            "Class %s not found on MATLAB path", className);
    end
    if ~isSubclass(className, "aod.core.Entity")
        error("navToRoot:InvalidClass",...
            "Class %s is not a subclass of aod.core.Entity", className);
    end

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
        case "schema"
            txt = strsplit(className, ".");
            fPath = fullfile(fPath, "schemas");
            for i = 1:(numel(txt)-1)
                fPath = fullfile(fPath, txt(i));
            end
            fPath = fullfile(fPath, txt(end)+".json");
    end
