function [T, errMap] = initializePackageSchemas(pkgFolder)
% INITIALIZEPACKAGESCHEMAS
%
% Description:
%   Initialize the schema folder and add all classes in the package
%
% Syntax:
%   T = aod.schema.util.initializePackageSchemas(pkgFolder)
%
% Inputs:
%   pkgFolder       string
%       The top-level "+" package folder
%
% Outputs:
%   T               table
%       Schema registry table (also written to registry.txt)
%   errMap          containers.Map
%       Keys are class names with bad schemas and values are error messages
%
% TODO: Hard reset option?? Add DateCreated and DateUpdated

% By Sara Patterson, 2024 (AOData)
% -------------------------------------------------------------------------

    txt = strsplit(pkgFolder, filesep);
    if endsWith(pkgFolder, filesep)
        pkgName = txt(end-1);
    else
        pkgName = txt(end);
    end
    if ~startsWith(pkgName, "+")
        error("Root folder must be a package folder starting with a '+'.");
    end
    pkgName = extractAfter(pkgName, "+");

    mp = meta.package.fromName(pkgName);
    if ~isempty(mp.ContainingPackage) || contains(mp.Name, '.')
        error("The parent folder cannot be a package folder.");
    end

    rootFolder = fileparts(pkgFolder);
    schemaFolder = fullfile(rootFolder, "schemas");
    if ~exist(schemaFolder, 'dir')
        mkdir(schemaFolder);
    end
    
    packageFolder = fullfile(schemaFolder, mp.Name);
    if ~exist(packageFolder, "dir")
        mkdir(packageFolder);
    end

    S = [];
    errMap = aod.common.KeyValueMap();
    if ~isempty(mp.ClassList)
        [S, errMap] = addClasses(packageFolder, mp, S, errMap);
    end
    for i = 1:numel(mp.PackageList)
        [S, errMap] = addSubpackage(packageFolder, mp.PackageList(i), S, errMap);
    end

    % Write the schema registry file
    T = table(arrayfun(@(x) x.Name, S)', 'VariableNames', {'Name'});
    f = string(fieldnames(S));
    for i = 2:numel(f)
        T.(f(i)) = arrayfun(@(x) x.(f(i)), S)';
    end
    writetable(T, fullfile(schemaFolder, "registry.txt"));

    % Warn user to check on errored schemas
    if errMap.Count > 0
        warning('%u classes had errors and could not be added', errMap.Count);
    end
end

function [S, errMap] = addClasses(packageFolder, mp, S, errMap)
    % ADDCLASSES  Write class json and add to registry
    % ---------------------------------------------------------------------
    for i = 1:numel(mp.ClassList)
        if mp.ClassList(i).Abstract
            continue
        end
        className = extractAfter(mp.ClassList(i).Name, [mp.Name, '.']);
        jsonFile = fullfile(packageFolder, [className, '.json']);
        try
            schema = aod.schema.util.StandaloneSchema(mp.ClassList(i).Name);
            if ~exist(jsonFile, 'file')
                schemaStruct = schema.struct();
                schemaStruct.SchemaVersion = ">0.1.0";
                schemaStruct.ClassVersion = 1;
                writestruct(schemaStruct, jsonFile);
            end
            S = [S, createClassStruct(mp.ClassList(i), packageFolder)];  %#ok<AGROW>
        catch ME
            if ~strcmp(ME.identifier, 'StandaloneSchema:InvalidClass')
                message = [mp.ClassList(i).Name, ' - ', ME.message];
                errMap(strrep(mp.ClassList(i).Name, '.', '_')) = [ME.identifier, '--> ', message];
                throwWarning(ME);
            end
        end
    end
end

function [S, errMap] = addSubpackage(parentFolder, mp, S, errMap)
    % ADDSUBPACKAGE  Write classes and recurse for more subpackages
    % ---------------------------------------------------------------------
    if isempty(mp.ClassList) && isempty(mp.PackageList)
        return
    end

    allPackageNames = strsplit(mp.Name, '.');
    packageFolder = fullfile(parentFolder, allPackageNames{end});
    if ~exist(packageFolder, "dir")
        mkdir(packageFolder);
    end

    if ~isempty(mp.ClassList)
        [S, errMap] = addClasses(packageFolder, mp, S, errMap);
    end

    for i = 1:numel(mp.PackageList)
        [S, errMap] = addSubpackage(packageFolder, mp.PackageList(i), S, errMap);
    end

    % Remove if folder and its subfolders do not contain AOData objects
    if numel(string(ls(packageFolder))) == 2
        rmdir(packageFolder);
    end
end

function S = createClassStruct(mc, packageFolder)
    % CREATECLASSSTRUCT  Create a structure containing class info
    % ---------------------------------------------------------------------
    S = struct('Name', string(mc.Name),...
        'Package', string(mc.ContainingPackage.Name),...
        'ClassVersion', 1,...
        'SchemaVersion', ">0.1.0",...
        'UUID', aod.infra.UUID.getClassUUID(mc.Name),...
        'SchemaPath', packageFolder);
end