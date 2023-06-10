function success = writeExpectedDatasets(hdfName, pathName, dsetName, DM, parentClass)
% Write aod.specification.DatasetManager as an HDF5 dataset
%
% Syntax:
%   success = aod.h5.writeExpectedAttributes(hdfName, pathName, dsetName,...
%       DM, parentClass)
%
% Inputs:
%   hdfName         char or H5ML.id
%       HDF5 file name or identifier
%   pathName        char
%       HDF5 path to group where dataset will be written
%   dsetName        char
%       Name of the dataset
%   DM              aod.specification.DatasetManager
%       Dataset manager to be written
% Optional inputs:
%   parentClass     string
%       Name of the parent class (default taken from DM's className)
%
% Outputs:
%   success         logical
%       Whether the DatasetManager was written or not
%
% See also:
%   aod.specification.DatasetManager, aod.h5.readExpectedDatasets

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    arguments
        hdfName
        pathName
        dsetName
        DM              {mustBeA(DM, 'aod.specification.DatasetManager')}
        parentClass     string = ""
    end
    
    if isempty(DM)
        warning('writeExpectedDatasets:Empty',...
            'Empty DatasetManager not written to %s', fullpath);
        success = false;
        return
    end

    if parentClass == ""
        parentClass = DM.className;
    end
    
    T = DM.table();
    h5tools.write(hdfName, pathName, dsetName, T);
    h5tools.writeatt(hdfName, h5tools.util.buildPath(pathName, dsetName),...
        'ParentClass', parentClass,...
        'DateWritten', datetime('now'));
    success = true;

    