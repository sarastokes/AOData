function T = initializePackageSchemas(pkgFolder)
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
%
% TODO: Hard reset option??

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
    if ~isempty(mp.ClassList)
        S = addClasses(packageFolder, mp, S);
    end
    for i = 1:numel(mp.PackageList)
        addSubpackage(packageFolder, mp.PackageList(i), S);
    end

    % Write the schema registry file
    T = table(arrayfun(@(x) x.Name, S)', 'VariableNames', {'Name'});
    f = string(fieldnames(S));
    for i = 2:numel(f)
        T.(f(i)) = arrayfun(@(x) x.(f(i)), S)';
    end
    writetable(T, fullfile(schemaFolder, "registry.txt"));

end

function S = addClasses(packageFolder, mp, S)
    % ADDCLASSES  Write class json and add to registry
    for i = 1:numel(mp.ClassList)
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
                rethrow(ME);
            end
        end
    end
end

function S = addSubpackage(parentFolder, mp, S)
    % ADDSUBPACKAGE  Write classes and recurse for more subpackages
    if isempty(mp.ClassList) && isempty(mp.PackageList)
        return
    end

    packageFolder = fullfile(parentFolder, mp.Name);
    if ~exist(packageFolder, "dir")
        mkdir(packageFolder);
    end

    if ~isempty(mp.ClassList)
        S = addClasses(packageFolder, mp, S);
    end

    for i = 1:numel(mp.PackageList)
        S = addSubpackage(packageFolder, mp.PackageList(i), S);
    end
end

function S = createClassStruct(mc, packageFolder)
    % CREATECLASSSTRUCT  Create a structure containing class info
    S = struct('Name', string(mc.Name),...
        'Package', string(mc.ContainingPackage.Name),...
        'ClassVersion', 1,...
        'SchemaVersion', ">0.1.0",...
        'UUID', aod.infra.UUID.getClassUUID(mc.Name),...
        'SchemaPath', packageFolder);
end