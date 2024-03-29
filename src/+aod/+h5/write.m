function success = write(hdfName, pathName, dsetName, data, description)
% Writes MATLAB dataset to an HDF5 dataset
%
% Syntax:
%   success = write(hdfName, pathName, dsetName, data)
%
% Inputs:
%   hdfName         char
%       The HDF5 file name
%   pathName        char
%       The HDF5 path for the group the dataset should be added to
%   dsetName        char
%       The name of the dataset
%   data            see supported data types
%       The data to write to the dataset
% Optional inputs:
%   description     string
%       A description of the dataset
%
% Outputs:
%   success         logical
%       Whether or not the data was successfully written to HDF5
%
% Supported data types:
%   numeric, char, string, logical, table, timetable, datetime, duration
%   enum, struct, containers.Map(), affine2d, imref2d, simtform2d, cfit
%   See h5tools-matlab documentation for limitations.
% AOData also adds support for aod.common.KeyValueMap and aod.common.FileReader
%
% See also:
%   h5tools.write, aod.h5.read, h5write
%
% TODO: Include Schema here?

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

        % Detailed input checking for first 4 is performed by h5tools
        arguments
            hdfName             char
            pathName            char
            dsetName            char
            data
            description         string      = []
        end

        fullPath = h5tools.util.buildPath(pathName, dsetName);

        if isa(data, 'aod.common.KeyValueMap')
            h5tools.datasets.makeTextDataset(hdfName, pathName, dsetName, "aod.common.KeyValueMap");
            h5tools.writeatt(hdfName, fullPath, 'Class', 'aod.common.KeyValueMap');
            success = true;
        elseif isSubclass(data, 'aod.common.FileReader')
            success = aod.h5.writeFileReader(hdfName, pathName, dsetName, data);
        else
            success = h5tools.write(hdfName, pathName, dsetName, data);
            % Description only written for datasets without mapped params
            if success && ~isempty(description)
                h5tools.writeatt(hdfName, fullPath, 'Description', description);
            end
        end
