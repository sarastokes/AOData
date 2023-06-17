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

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------
    
    % No need for argument checking that occurs in h5tools.read
    arguments
        hdfName         
        pathName
        dsetName
        className       string    = [];
    end

    fullPath = h5tools.util.buildPath(pathName, dsetName);
    if aod.util.isempty(className) && h5tools.hasAttribute(hdfName, fullPath, 'Class')
        className = h5tools.readatt(hdfName, fullPath, 'Class');
    end

    % Deal with AOData-specific classes first
    if strcmp(className, "aod.common.KeyValueMap")
        out = h5tools.readatt(hdfName, fullPath, 'all');
        out = map2attributes(out);
        return
    end

    if strcmp(className, "aod.common.FileReader")
        out = aod.h5.readFileReader(hdfName, pathName, dsetName);
        return
    end
    
    if strcmp(dsetName, "expectedAttributes")
        out = aod.h5.readExpectedAttributes(hdfName, pathName, dsetName);
        return
    end

    if strcmp(dsetName, "expectedDatasets")
        out = aod.h5.readExpectedDatasets(hdfName, pathName, dsetName);
        return
    end

    % Generic HDF5 datasets
    out = h5tools.read(hdfName, pathName, dsetName);

    

    % Deal with AOData-specific classes that weren't flagged by user
    if isstring(out) && isscalar(out) 
        if isequal(out, "aod.common.KeyValueMap")
            out = h5tools.readatt(hdfName, fullPath, 'all');
        elseif isSubclass(out, "aod.common.FileReader")
            %! This has some redundancies to cut for speed
            out = aod.h5.readFileReader(hdfName, pathName, dsetName);
        end
    end