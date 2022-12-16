function out = read(hdfName, pathName, dsetName, className)
% Read an HDF5 dataset
%
% Description:
%   Reads an HDF5 dataset with extra processing for AOData-specific classes
%
% Syntax:
%   out = aod.h5.read(hdfName, pathName, dsetName)
%   out = aod.h5.read(hdfName, pathName, dsetName, className)
% 
% See Also: 
%   h5tools.read

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------
    
    % No need for argument checking that occurs in h5tools.read
    arguments
        hdfName         
        pathName
        dsetName
        className       char    = [];
    end

    fullPath = h5tools.util.buildPath(pathName, dsetName);

    % Deal with AOData-specific classes first
    if isequal(className, "aod.util.Parameters")
        out = h5tools.readatt(hdfName, fullPath, 'all');
        return
    end
    
    out = h5tools.read(hdfName, pathName, dsetName);

    % Deal with AOData-specific classes that weren't flagged by user
    if isstring(out) && isscalar(out) && isequal(out, "aod.util.Parameters")
        out = h5tools.readatt(hdfName, fullPath, 'all');
    end