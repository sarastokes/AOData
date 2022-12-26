function success = write(fileName, pathName, dsetName, data, description)
% Writes MATLAB dataset to an HDF5 dataset 
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
% AOData also adds support for aod.util.Parameters and aod.util.FileReader
%
% See also:
%   h5tools.write, aod.h5.read, aod.h5.writeFileReader

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------
    
        % Detailed input checking for first 4 is performed by h5tools
        arguments
            fileName            char 
            pathName            char 
            dsetName            char 
            data
            description         string      = []
        end
    
        fullPath = h5tools.util.buildPath(pathName, dsetName);
    
        if isa(data, 'aod.util.Parameters')
            h5tools.datasets.makeTextDataset(fileName, pathName, dsetName, "aod.util.Parameters");
            h5tools.writeatt(fileName, fullPath, data);
            success = true;
        % elseif isSubclass(data, 'aod.util.FileReader')
        %     aod.h5.writeFileReader(fileName, pathName, dsetName, data, description);
        %     success = true;
        else
            success = h5tools.write(fileName, pathName, dsetName, data);
            % Description only written for datasets without mapped params
            if ~isempty(description)
                h5tools.writeatt(fileName, fullPath, 'Description', description);
            end
        end
        