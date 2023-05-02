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

    % Convert to DatasetManager
    DM = aod.util.DatasetManager();
    numDsets = height(T);
    for i = 1:numDsets
        try
            if T.Default(i) == ""
                default = string.empty();
            else
                eval(sprintf('default = %s;', T.Default(i)));
            end
        catch
            warning("readExpectedParameters:DefaultEvalError",...
                "Could not evaluate %s", T.Default(i));
            default = [];
        end
        try
            if T.Validation(i) == ""
                validation = [];
            else
                eval(sprintf('validation = %s;', T.Validation(i)));
            end
        catch 
            warning("readExpectedParameters:ValidationEvalError",...
                "Could not evaluate %s", T.Validation(i));
            validation = [];
        end
        DM.add(T.Name(i), T.Class(i), default, validation, T.Description(i), T.Units(i));
    end
