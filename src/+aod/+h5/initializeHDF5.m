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
    % ---------------------------------------------------------------------

    assert(endsWith(hdfName, '.h5'), 'File name must end with .h5');
    
    import aod.h5.HDF5

    fileID = H5F.create(hdfName);
    HDF5.createGroups(hdfName, '/', 'Experiment');

    mainGroups = {'Epochs', 'Calibrations', 'Regions', 'Systems', 'Sources', 'Analyses'};
    HDF5.createGroups(hdfName, '/Experiment', mainGroups{:});

    for i = 1:numel(mainGroups)
        HDF5.writeatts(hdfName, ['/Experiment/', mainGroups{i}],... 
            'Class', 'Container');
    end

    H5F.close(fileID);
    