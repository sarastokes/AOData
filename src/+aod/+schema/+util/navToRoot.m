function fPath = navToRoot(className)

    fPath = which(className);

    while ~exist(fullfile(fPath, 'schema'), 'dir')
        if endsWith(fPath, 'src')
            fPath = [];
            return
        end
        fPath = fileparts(fPath);
    end