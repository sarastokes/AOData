function [status, datasetNames] = datasetVisitFcn(rootID, name, datasetNames)
    % DATASETVISITFCN
    %
    % Description:
    %   Visit function to iterate through an HDF5 file
    %
    % Syntax:
    %   [status, dsetNames] = datasetVisitFcn(rootID, name, dsetNames)
    %
    % Inputs:
    %   datasetNames           string
    %
    % Use:
    %   datasetNames = string.empty()
    %   [~, datasetNames] = H5O.visit(fileID, 'H5_INDEX_NAME',...
    %       'H5_ITER_NATIVE', @datasetVisitFcn, datasetNames)
    %   
    % Notes:
    %   Having trouble getting H5O.visit to use this function while it's in
    %   a package. Saving here for now.
    %
    % See also:
    %   aod.h5.HDF5.collectDatasets
    %
    % History:
    %   20Nov2022 - SSP
    % ---------------------------------------------------------------------

    objID = H5O.open(rootID, name, 'H5P_DEFAULT');
    info = H5O.get_info(objID);
    H5O.close(objID);

    if string(name) == "."
        status = 0;
        return
    end

    if info.type == H5ML.get_constant_value('H5O_TYPE_DATASET')
        datasetNames = cat(1, datasetNames, "/" + string(name));
    end

    status = 0;