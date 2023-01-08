function deleteTestFiles()
% Delete the HDF5 and .m files created while running the test suite
%
% Syntax:
%   deleteTestFiles()

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------
    currentPWD = pwd;

    cd(fullfile(getpref('AOData', 'BasePackage'), 'test'));

    if exist('ToyExperiment.h5', 'file')
        delete('ToyExperiment.h5');
    end
    if exist('HdfTest.h5', 'file')
        delete('HdfTest.h5');
    end
    if exist('Demo2.m', 'file')
        delete('Demo2.m');
    end
    cd(currentPWD);