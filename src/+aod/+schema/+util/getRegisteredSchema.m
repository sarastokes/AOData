function schema = getRegisteredSchema(className)
% GETREGISTEREDSCHEMA
%
% Syntax:
%   schema = aod.schema.util.getRegisteredSchema(className)
% --------------------------------------------------------------------------

    fPath = aod.schema.util.navToRoot(className);
    schemaPath = fullfile(fPath, 'schema');

    if ~exist(schemaPath, 'dir')
        error('No schema directory found for class %s', className);
    end

    try
        registry = loadjson(fullfile(schemaPath, 'registry.json'));
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
