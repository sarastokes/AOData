function [DMs, AMs, S] = collectPackageSpecifications(pkgName, varargin)
% Collect all the specifications for a package
%
% Syntax:
%   [DM, S] = aod.specification.collectPackageSpecifications(pkgName, writeToFile)
%
% Inputs:
%   pkgName             string
%       Package name
%   writeToFile         logical
%       Whether to write the specification
%
% Outputs:
%   DMs                 aod.specification.DatasetManager
%       All the dataset managers
%   AMs                 aod.specification.AttributeManager
%       All the attribute managers
%   S                   struct
%       The structure written to JSON

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    pkgName = convertCharsToStrings(pkgName);

    ip = aod.util.InputParser();
    addParameter(ip, 'Write', false, @islogical);
    addParameter(ip, 'Subpackages', false, @islogical);
    parse(ip, varargin{:});

    mp = meta.package.fromName(pkgName);
    if isempty(mp)
        error('collectPackageSpecification:PackageDoesNotExist',...
            "Package ""%s"" not found.", pkgName);
    end

    logger = aod.specification.logger.SpecificationLogger(...
        sprintf("Package_%s", pkgName));

    if ip.Results.Subpackages
        [classes, pkgs] = aod.specification.util.collectAllPackageClasses(pkgName);
        S = struct('DateCreated', jsonencode(datetime('now')));
        DMs = []; AMs = [];
        for i = 1:numel(pkgs)
            [iS, iAMs, iDMs] = getPkgStruct(pkgs(i), logger);
            AMs = cat(1, AMs, iAMs);
            DMs = cat(1, DMs, iDMs);
            S = mergeNestedStructs(S, iS);
        end
    else
        classes = string({mp.ClassList.Name})';
        [S, AMs, DMs] = getPkgStruct(pkgName, logger);
        S.DateCreated = jsonencode(datetime('now'));
    end


    if ip.Results.Write
        pkgFileName = strrep(pkgName, ".", "_") + ".json";
        if ~exist(pkgFileName, 'file')
            savejson('', S, pkgFileName);
        end
    end
end

function [S, AMs, DMs] = getPkgStruct(pkgName, logger)
    mp = meta.package.fromName(pkgName);
    classes = string({mp.ClassList.Name})';

    S = struct();
    S.Classes = struct();
    DMs = []; AMs = [];
    for i = 1:numel(classes)
        try
            DM = aod.specification.util.getDatasetSpecification(...
                mp.ClassList(i));
        catch ME
            if strcmp(ME.identifier, 'getDatasetSpecification:InvalidClass')
                continue
            else
                DM = [];
                logger.write(classes(i), "Dataset", "ERROR", ME);
            end
        end

        try
            AM = aod.specification.util.getAttributeSpecification(...
                mp.ClassList(i));
        catch ME
            AM = [];
            logger.write(classes(i), "Attribute", "ERROR", ME);
        end

        if isempty(DM) && isempty(AM)
            continue
        end

        DMs = cat(1, DMs, DM);
        AMs = cat(1, AMs, AM);

        soloName = extractAfter(classes(i), [mp.Name, '.']);

        S.Classes.(soloName) = struct();
        if ~isempty(DM)
            S.Classes.(soloName).Datasets = DM.struct();
        end
        if ~isempty(AM)
            S.Classes.(soloName).Attributes = AM.struct();
        end
        S.Classes.(soloName).Name = soloName;
    end

    [pkgs, fullNames] = collectPackages(meta.package.fromName(pkgName));

    for i = 1:numel(pkgs)
        tmpStruct = struct();
        tmpStruct.Namespaces = struct();
        tmpStruct.Namespaces.(pkgs(i)) = S;
        tmpStruct.Namespaces.(pkgs(i)).Name = pkgs(i);
        tmpStruct.Namespaces.(pkgs(i)).Package = fullNames(i);
        S = tmpStruct;
    end
end

function [pkgs, fullNames] = collectPackages(mp)
    pkgs = string(mp.Description);
    while ~isempty(mp.ContainingPackage)
        pkgs = cat(1, pkgs, mp.ContainingPackage.Description);
        mp = mp.ContainingPackage;
    end

    fullNames = [];
    for i = 1:numel(pkgs)
        fullName = pkgs(i);
        if i < numel(pkgs)
            for j = i+1:numel(pkgs)
                fullName = pkgs(j) + "." + fullName;
            end
        end
        fullNames = cat(1, fullNames, fullName);
    end
end