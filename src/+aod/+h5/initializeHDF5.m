function initializeHDF5(hdfName)
    % INITIALIZEHDF5
    %
    % Syntax:
    %   initializeHDF5(hdfName)
    %
    % History:
    %   10Aug2022 - SSP
    % ---------------------------------------------------------------------

    import aod.h5.HDF5

    fileID = H5F.create(hdfName);
    HDF5.createGroups(hdfName, '/', 'Experiment');

    mainGroups = {'Epochs', 'Calibrations', 'Regions', 'System', 'Sources', 'Stimuli'};
    HDF5.createGroups(hdfName, '/Experiment', mainGroups{:});

    HDF5.createGroups(hdfName,  '/Experiment/Stimuli',...
        {'Protocols', 'Presentations'});
    H5F.close(fileID);
    