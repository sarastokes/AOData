function success = write(fileName, pathName, dsetName, data)
% Writes MATLAB dataset with attributes signaling the MATLAB datatype 
%
% Syntax:
%   success = write(fileName, pathName, dsetName, data)
%
% Inputs:
%   fileName        char
%       The HDF5 file name
%   pathName        char
%       The HDF5 path for the group the dataset should be added to
%   dsetName        char
%       The name of the dataset
%   data            see supported data types
%       The data to write to the dataset
%
% Outputs:
%   success         logical
%       Whether or not the data was successfully written to HDF5
%
% Supported data types:
%   numeric, char, string, logical, table, timetable, datetime, duration
%   enum, struct, containers.Map(), affine2d, imref2d, simtform2d, cfit
% See README.md for limitations - essentially no multilevel data (e.g. 
%   structs/tables/containers.Maps that contain other tables, structs or 
%   containers.Maps
%
% See also:
%   h5tools.write

% By Sara Patterson, 2022 (h5tools-matlab)
% -------------------------------------------------------------------------

    arguments
        fileName            char 
        pathName            char 
        dsetName            char 
        data
    end

    fullPath = h5tools.util.buildPath(pathName, dsetName);

    if isa(data, 'aod.util.Parameters')
        h5tools.datasets.makeTextDataset(fileName, pathName, dsetName, "aod.util.Parameters");
        h5tools.writeatt(fileName, fullPath, data);
    else
        h5tools.write(fileName, pathName, dsetName, data);
    end
    success = true;