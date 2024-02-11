function T = loadSchemaRegistry(fPath)
    
    if ~endsWith(fPath, "registry.txt")
        fPath = fullfile(fPath, "registry.txt");
    end
    if ~exist(fPath, 'file')
        error('loadSchemaRegistry:InvalidFile',...
            'Registry file not found: %s', fPath);
    end
    T = readtable(fPath, "Delimiter", ",");
    T = convertTableCellstr2String(T);
