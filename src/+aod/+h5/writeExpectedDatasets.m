function success = writeExpectedDatasets(hdfName, pathName, dsetName, DM)
% Write aod.util.DatasetManager as an HDF5 dataset
%
% Syntax:
%   success = aod.h5.writeExpectedParameters(hdfName, pathName, dsetName, PM)
%
% Inputs:
%   hdfName         char or H5ML.id
%       HDF5 file name or identifier
%   pathName        char
%       HDF5 path to group where dataset will be written
%   dsetName        char
%       Name of the dataset
%   PM              aod.util.DatasetManager
%       Dataset manager to be written
%
% Outputs:
%   success         logical
%       Whether the DatasetManager was written or not
%
% See also:
%   aod.util.DatasetManager, aod.h5.readExpectedDatasets

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

arguments
    hdfName
    pathName
    dsetName
    DM          {mustBeA(DM, 'aod.util.DatasetManager')}
end

if isempty(DM)
    warning('writeExpectedDatasets:Empty',...
        'Empty DatasetManager not written to %s', fullpath);
    success = false;
    return
end

T = DM.table();
h5tools.write(hdfName, pathName, dsetName, T);
success = true;

    