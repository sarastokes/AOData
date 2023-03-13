function deleteTestFiles()
% Delete the HDF5 and .m files created while running the test suite
%
% Syntax:
%   deleteTestFiles()

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------
    currentPWD = pwd;

    cd(test.util.getAODataTestFolder());

    if exist('ToyExperiment.h5', 'file')
        delete('ToyExperiment.h5');
    end

    if exist('ToyExperiment.mat', 'file')
        delete('ToyExperiment.mat');
    end

    if exist('SmallExperiment.h5', 'file')
        delete('SmallExperiment.h5');
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