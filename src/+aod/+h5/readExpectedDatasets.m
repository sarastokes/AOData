function DM = readExpectedDatasets(hdfName, pathName, dsetName)
% Read aod.util.DatasetManager
%
% Syntax:
%   DM = aod.h5.readExpectedDatasets(hdfName, pathName, dsetName)
%
% Inputs:
%   hdfName         char or H5ML.id
%       HDF5 file name or identifier
%   pathName        char
%       HDF5 path to group where dataset will be written
%   dsetName        char
%       Name of the dataset
%
% Outputs:
%   DM              aod.util.DatasetManager

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    % Read in as a table
    T = h5tools.read(hdfName, pathName, dsetName);

    % Get the parent class name
    className = h5tools.readatt(hdfName, ...
        h5tools.util.buildPath(pathName, dsetName), 'ParentClass');

    % Convert to DatasetManager
    DM = aod.specification.DatasetManager(className);
    numDatasets = height(T);

    for i = 1:numDatasets
        name = T.Name(i);
        description = T.Description(i);
        matClass = T.Class(i);
        sizing = T.Size(i);
        if T.Default(i) == "[]"
            default = [];
        else
            eval(sprintf('default = %s;', T.Default(i)));
        end
        if T.Functions(i) == "[]"
            fcns = [];
        else
            eval(sprintf('fcns = %s;', T.Functions(i)));
        end

        D = aod.specification.Dataset(name,...
            "Description", description,...
            "Class", matClass,...
            "Size", sizing,...
            "Function", fcns,...
            "Default", default);
        DM.add(D);
    end
