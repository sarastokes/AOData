function T = loadSchemaRegistry(fPath)
% LOADSCHEMAREGISTRY
%   
% Syntax:
%   T = aod.schema.util.loadSchemaRegistry(fPath)
%
% Input:
%   fPath           string
%       File path to registry.txt, parent schema folder or root dir
% Output:
%   T               table
%
% Throws:
%   loadSchemaRegistry:InvalidInput
%       When input isn't a valid folder or file path
%   loadSchemaRegistry:RegistryNotFound
%       When there is no registry.txt file to load
%
% Examples:
%   T = loadSchemaRegistry("C:\AOData\src\schemas\registry.txt")
%   T = loadSchemaRegistry("C:\AOData\src\schemas\")
%   T = loadSchemaRegistry("C:\AOData\src")

% By Sara Patterson, 2024 (AOData)
% -------------------------------------------------------------------------

    if ~exist(fPath, "file") && ~exist(fPath, "folder")
        error("loadSchemaRegistry:InvalidInput",...
            "Input must be valid file or folder path - %s not found", fPath);
    end
    
    if ~endsWith(fPath, "registry.txt")
        if ~endsWith(fPath, ["schemas", "schemas"+filesep])
            fPath = fullfile(fPath, "schemas", "registry.txt");
        else
            fPath = fullfile(fPath, "registry.txt");
        end
    end

    if ~exist(fPath, 'file')
        error('loadSchemaRegistry:RegistryNotFound',...
            'Registry file not found: %s', fPath);
    end

    T = readtable(fPath, "Delimiter", ",");
    T = convertTableCellstr2String(T);
