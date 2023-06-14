function [DMs, S] = collectPackageSpecifications(pkgName, writeToFile)
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

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    if nargin < 2
        writeToFile = false;
    end

    mp = meta.package.fromName(pkgName);
    [pkgs, fullNames] = collectPackages(mp);

    classes = string({mp.ClassList.Name})';

    S = struct();
    S.Classes = struct();
    DMs = []; AMs = [];
    for i = 1:numel(classes)
        try
            DM = processClassDatasets(mp.ClassList(i));
            AM = processClassAttributes();
        catch ME 
            if strcmp(ME.identifier, 'populate:InvalidInput')
                % Class is not an aod.core.Entity subclass and does not
                % need a written specification.
                continue
            else
                rethrow(ME);
            end
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

    if writeToFile
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

function DM = processClassDatasets(mc)
    expectedDatasets = aod.specification.DatasetManager.populate(mc);
    fcn = str2func(sprintf("@(x) %s.specifyDatasets(x)", mc.Name));
    DM = fcn(expectedDatasets);
end

function AM = processClassAttributes(mc)
    fcn = str2func(sprintf("%s.specifyAttributes()", mc.Name));
    AM = fcn();
end