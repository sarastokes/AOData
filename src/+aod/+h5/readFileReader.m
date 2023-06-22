function reader = readFileReader(hdfName, pathName, dsetName)
% Read a file reader from an HDF5 file
%
% Description:
%   Creates the FileReader and assigns any attributes to properties
%
% Syntax:
%   reader = aod.h5.readFileReader(hdfName, pathName, dsetName)
%
% Inputs:
%   hdfName         char or H5ML.id
%       HDF5 file name or identifier
%   pathName        char
%       HDF5 path to group where dataset will be written
%   dsetName        char
%       Name of the dataset
%
% Outputs:
%   reader          aod.common.FileReader
%       The file reader, if present in MATLAB search path
%
% See also:
%   aod.h5.writeFileReader, aod.common.FileReader

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    fullPath = h5tools.util.buildPath(pathName, dsetName);
    readerName = h5read(hdfName, fullPath);

    allAttrs = h5tools.readatt(hdfName, fullPath, 'all');

    if ~exist(readerName, 'class')
        warning('readFileReader:OffPath',...
            'No class named %s found on MATLAB path, reading as a keyvaluemap', readerName);
        S = map2attributes(allAttrs);
        S('Reader') = readerName;
    end

    constructor = str2func(readerName);
    reader = constructor(allAttrs('fullFile'));
    
    k = allAttrs.keys;
    for i = 1:numel(k)
        p = findprop(reader, k{i});
        if ~isempty(p) && strcmp(p.SetAccess, 'public')
            reader.(k{i}) = allAttrs(k{i});
        end
    end