function fPath = navToRoot(className)
% NAVTOROOT  Navigate to root package folder
%
% Description:
%   Navigate to the root package folder that contains schemas.
%
% Syntax:
%   fPath = aod.schema.util.navToRoot(className)
%
% Inputs:
%   className           string/char
%       The name of the AOData class
%
% Outputs:
%   fPath               string/char
%       The file path to the folder containing schemas

% By Sara Patterson, 2024 (AOData)
% -------------------------------------------------------------------------

    fPath = which(className);

    while ~exist(fullfile(fPath, 'schemas'), 'dir')
        if isequal(fPath, fileparts(fPath)) || aod.util.isempty(fPath)
            fPath = [];
            return
        end
        fPath = fileparts(fPath);
    end