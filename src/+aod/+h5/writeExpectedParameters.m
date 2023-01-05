function success = writeExpectedParameters(hdfName, pathName, dsetName, PM)
% Write aod.util.ParameterManager as an HDF5 dataset
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
%   PM              aod.util.ParameterManager
%       Parameter manager to be written
%
% Outputs:
%   success         logical
%       Whether the ParameterManager was written or not
%
% See also:
%   aod.util.ParameterManager, aod.h5.readExpectedParameters

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    arguments
        hdfName
        pathName
        dsetName
        PM          {mustBeA(PM, 'aod.util.ParameterManager')}
    end

    fullPath = h5tools.util.buildPath(pathName, dsetName);
    if isempty(PM)
        warning('writeExpectedParameters:Empty',...
            'Empty ParameterManager not written to %s', fullpath);
        success = false;
        return
    end

    T = PM.table();
    h5tools.write(hdfName, pathName, dsetName, T);
    % h5tools.writeatt(hdfName, fullPath, 'Class', 'aod.util.ParameterManager');
    success = true;
