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

    ip = aod.util.InputParser();
    addParameter(ip, 'Write', false, @islogical);
    addParameter(ip, 'Subpackages', false, @islogical);
    parse(ip, varargin{:});

    mp = meta.package.fromName(pkgName);
    if isempty(mp)
        error('collectPackageSpecification:PackageDoesNotExist',...
            "Package ""%s"" not found.", pkgName);
    end
    [pkgs, fullNames] = collectPackages(mp);

    if ip.Results.Subpackages
        classes = collectPackageSpecifications(pkgName);
    else
        classes = string({mp.ClassList.Name})';
    end
    
    logger = aod.specification.logger.SpecificationLogger(...
        sprintf("Package_%s", pkgName));
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
                logger.write(classes(i), "Dataset", "ERROR", ME);
            end
        end

        try 
            AM = aod.specification.util.getAttributeSpecification(...
                mp.ClassList(i));
        catch ME 
            logger.write(classes(i), "Attribute", "ERROR", ME);
        end

        if isempty(DM) && isempty(AM)
            continue
        end

        DMs = cat(1, DMs, DM);
        AMs = cat(1, AMs, AM);

        soloName = extractAfter(classes(i), [mp.Name, '.']);

        S.Classes.(soloName) = struct();
        S.Classes.(soloName).Datasets = DM.struct();
        S.Classes.(soloName).Name = soloName;
    end

    for i = 1:numel(pkgs)
        tmpStruct = struct();
        tmpStruct.Namespace = struct();
        tmpStruct.Namespace.(pkgs(i)) = S;
        tmpStruct.Namespace.(pkgs(i)).Name = pkgs(i);
        tmpStruct.Namespace.(pkgs(i)).Namespace = fullNames(i);
        S = tmpStruct;
    end

    S.DateCreated = jsonencode(datetime('now'));

    if ip.Results.Write
        pkgFileName = strrep(pkgName, ".", "_") + ".json";
        if ~exist(pkgFileName, 'file')
            savejson('', S, pkgFileName);
        end
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