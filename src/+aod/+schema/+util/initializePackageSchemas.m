function initializePackageSchemas(pkgFolder)
% INITIALIZEPACKAGESCHEMAS
%
% Syntax:
%   initializePackageSchemas(pkgFolder)
%
% TODO: Hard reset option??

% By Sara Patterson, 2024 (AOData)
% ------------------------------------------------------------------------

    txt = strsplit(pkgFolder, filesep);
    if endsWith(pkgFolder, filesep)
        pkgName = txt(end-1);
    else
        pkgName = txt(end);
    end
    if ~startsWith(pkgName, "+")
        error("The root folder must be a package folder, i.e. start with a '+' sign.");
    end

    mp = meta.package.fromName(pkgName);
    if ~isempty(mp.ContainingPackage)
        error("The parent folder cannot be a package folder.");
    end

    rootFolder = fileparts(pkgFolder);
    schemaFolder = fullfile(rootFolder, "schemas");
    if ~exist(schemaFolder, 'dir')
        mkdir(schemaFolder, "schemas");
    end

    S = [];
    for i = 1:numel(mp.ClassList)
        % TODO: write the class schema file
        className = extractAfter(mp.ClassList(i).Name, [mp.Name, '.']);
        savejson('', schemaText, fullfile(schemaFolder, [className, '.json']));
        S = [S, createClassStruct(mp.ClassList(i), packageFolder)];  %#ok<AGROW>
    end

    for i = 1:numel(mp.PackageList)
        addSubpackage(parentFolder, mp.PackageList(i), S);
    end
end

function S = addSubpackage(parentFolder, mp, S)
    if isempty(mp.ClassList) && isempty(mp.PackageList)
        return
    end

    packageFolder = fullfile(parentFolder, mp.Name);
    if ~exist(packageFolder, "dir")
        mkdir(packageFolder);
    end

    for i = 1:numel(mp.ClassList)
        % TODO: write the class schema file
        S = [S, createClassStruct(mp.ClassList(i), packageFolder)];  %#ok<AGROW>
    end

    for i = 1:numel(mp.PackageList)
        S = addSubpackage(packageFolder, mp.PackageList(i), S);
    end
end

function S = createClassStruct(mc, packageFolder)
    S = struct('Name', mp.Name,...
        'Package', mc.ContainingPackage.Name,...
        'ClassVersion', 1,...
        'SchemaVersion', ">0.1.0",...
        'UUID', "",...
        'SchemaPath', extractAfter(packageFolder, "schemas" + filesep));
end