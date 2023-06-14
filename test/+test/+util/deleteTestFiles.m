function deleteTestFiles()
% Delete the HDF5 and .m files created while running the test suite
%
% Syntax:
%   aod.util.deleteTestFiles()

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------
    currentPWD = pwd;

    cd(test.util.getAODataTestFolder());

    if exist('ToyExperiment.h5', 'file')
        delete('ToyExperiment.h5');
    end

    if exist('ToyExperiment.mat', 'file')
        delete('ToyExperiment.mat');
    end

    if exist('CommonApiTest.h5', 'file')
        delete('CommonApiTest.h5');
    end

    if exist('EntityRenameTest.h5', 'file')
        delete('EntityRenameTest.h5');
    end

    if exist('EntityDeletionTest.h5', 'file')
        delete('EntityDeletionTest.h5');
    end

    if exist('FileReaderTest.h5', 'file')
        delete('FileReaderTest.h5');
    end

    if exist('SmallExperiment.h5', 'file')
        delete('SmallExperiment.h5');
    end

    if exist('ShellExperiment.h5', 'file')
        delete('ShellExperiment.h5');
    end

    if exist('PersistentInterface.h5', 'file')
        delete('PersistentInterface.h5');
    end
    
    if exist('HdfTest.h5', 'file')
        delete('HdfTest.h5');
    end

    if exist('DeviceSubclass.m', 'file')
        delete('DeviceSubclass.m');
    end

    if exist('Demo2.m', 'file')
        delete('Demo2.m');
    end
    
    cd(currentPWD);