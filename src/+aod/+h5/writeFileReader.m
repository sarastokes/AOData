function success = writeFileReader(hdfName, pathName, dsetName, reader)
% Write aod.common.FileReader as an HDF5 dataset
%
% Syntax:
%   success = aod.h5.writeFileReader(hdfName, pathName, dsetName, reader)
%
% Inputs:
%   hdfName         char or H5ML.id
%       HDF5 file name or identifier
%   pathName        char
%       HDF5 path to group where dataset will be written
%   dsetName        char
%       Name of the dataset
%   reader          aod.common.FileReader
%       File reader to be written
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
        reader          {mustBeA(reader, 'aod.common.FileReader')}
    end

    fullPath = h5tools.util.buildPath(pathName, dsetName);

    h5tools.write(hdfName, pathName, dsetName, string(class(reader)));
    h5tools.writeatt(hdfName, fullPath,...
        'Class', 'aod.common.FileReader');

    % Write user-defined properties that have public get access
    expectedProperties = ["Data"];
    mc = metaclass(reader);
    for i = 1:numel(mc.PropertyList)
        if ~ismember(mc.PropertyList(i).Name, expectedProperties) ...
                && strcmp(mc.PropertyList(i).GetAccess, 'public') 
            h5tools.writeatt(hdfName, fullPath, mc.PropertyList(i).Name,...
                reader.(mc.PropertyList(i).Name));
        end
    end

    success = true;