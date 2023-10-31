function fPath = getResourceDir(obj, makeIfAbsent)
% GETRESOURCEDIR
%
% Syntax:
%   fPath = aod.schema.util.getResourceDir(obj, makeIfAbsent)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    arguments
        obj
        makeIfAbsent    (1,1)       logical     = false
    end

    obj = convertCharsToStrings(obj);
    if ~isstring(obj)
        obj = string(class(obj));
    end

    if exist(obj, "class")
        fPath = fullfile(fileparts(which(obj)), "resources");
    else
        try
            mp = meta.package.fromName(obj);
        catch
            error('getResourceDir:InvalidInput',...
                'Input %s does not match a class or a package', obj);
        end
        fPath = fullfile(fileparts(which(mp.ClassList(1).Name)), "resources");
    end

    fPath = convertCharsToStrings(fPath);

    if makeIfAbsent && ~exist(fPath, "dir")
        mkdir(fPath);
        fprintf("Created %s\n", fPath);
    end