function deleteTestFiles()
    % DELETETESTFILES
    %
    % Description:
    %   Delete the HDF5 files created while running the test suite
    %
    % Syntax:
    %   deleteTestFiles()
    % ---------------------------------------------------------------------
    currentPWD = pwd;

    cd(fullfile(getpref('AOData', 'BasePackage'), 'test'));

    if exist('ToyExperiment.h5', 'file')
        delete('ToyExperiment.h5');
    end
    if exist('HdfTest.h5', 'file')
        delete('HdfTest.h5');
    end
    cd(currentPWD);