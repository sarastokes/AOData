function success = writeExpectedAttributes(hdfName, pathName, dsetName, PM)
% Write aod.util.AttributeManager as an HDF5 dataset
%
% Syntax:
%   success = aod.h5.writeExpectedAttributes(hdfName, pathName, dsetName, PM)
%
% Inputs:
%   hdfName         char or H5ML.id
%       HDF5 file name or identifier
%   pathName        char
%       HDF5 path to group where dataset will be written
%   dsetName        char
%       Name of the dataset
%   PM              aod.util.AttributeManager
%       Attribute manager to be written
%
% Outputs:
%   success         logical
%       Whether the AttributeManager was written or not
%
% See also:
%   aod.util.AttributeManager, aod.h5.readExpectedAttributes

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    arguments
        hdfName
        pathName
        dsetName
        PM          {mustBeA(PM, 'aod.util.AttributeManager')}
    end

    if isempty(PM)
        warning('writeExpectedAttributes:Empty',...
            'Empty AttributeManager not written to %s', fullpath);
        success = false;
        return
    end

    T = PM.table();
    h5tools.write(hdfName, pathName, dsetName, T);
    success = true;
