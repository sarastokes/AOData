function initializeHDF5(hdfName)
    % INITIALIZEHDF5
    %
    % Description:
    %   Creates a template HDF5 file
    %
    % Syntax:
    %   initializeHDF5(hdfName)
    %
    % History:
    %   10Aug2022 - SSP
    %   28Aug2022 - SSP - Containers for experiment now in writeEntity
    % ---------------------------------------------------------------------

    assert(endsWith(hdfName, '.h5'), 'File name must end with .h5');
    
    import aod.h5.HDF5

    fileID = H5F.create(hdfName);
    HDF5.createGroups(hdfName, '/', 'Experiment');

    H5F.close(fileID);
    