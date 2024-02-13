function schema = getRegisteredSchema(className)
% GETREGISTEREDSCHEMA
%
% Syntax:
%   schema = aod.schema.util.getRegisteredSchema(className)

% By Sara Patterson, 2024 (AOData)
% -------------------------------------------------------------------------

    fPath = aod.schema.util.navToRoot(className);
    schemaPath = fullfile(fPath, 'schemas');

    if ~exist(schemaPath, 'dir')
        error('No schema directory found for class %s', className);
    end

    try
        registry = aod.schema.util.loadSchemaRegistry(fullfile(schemaPath, 'registry.txt'));
        % TODO: Find version number
    catch
        warning('No registry found for package containing %s', className);
        schema = [];
        return
    end

    names = strsplit(className, ".");
    for i = 1:numel(names)-1
        schemaPath = fullfile(schemaPath, names(i));
    end

    schemaFile = fullfile(schemaPath, [names(end) '.json']);
    schema = loadjson(schemaFile);

    % TODO: Get versioned number.
