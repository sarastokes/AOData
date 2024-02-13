function registries = collectRegistries()
% COLLECTREGISTRIES
%
% Description:
%   Collect all schema registries in packages on AOData's search path
%
% Syntax:
%   registries = aod.schema.util.collectRegistries()
%
% Output:
%   registries          table
%       Table of all schemas found on path (concatenated registries)
%
% Notes:
%   Only packages added to AOData's search path are considered. To see which
%   packages are included, check "getpref('AOData', 'SearchPaths'). To add
%   new packages, use AODataManagerApp()
%
% See also:
%   AODataManagerApp, aod.schema.util.loadSchemaRegistry

% By Sara Patterson, 2024 (AOData)
% -------------------------------------------------------------------------

    registryFiles = [];
    paths = getpref('AOData', 'SearchPaths');
    paths = strsplit(paths, ';');
    for i = 1:numel(paths)
        S = subdir(fullfile(paths{i}, '*registry.txt'));
        if isempty(S)
            continue
        end
        registryFiles = [registryFiles; arrayfun(@(x) string(x.name), S)];  %#ok<AGROW>
    end

    if isempty(registryFiles)
        registries = table.empty();
        return
    end

    registries = arrayfun(@(x) aod.schema.util.loadSchemaRegistry(x), ...
        registryFiles, 'UniformOutput', false);
    registries = vertcat(registries{:});