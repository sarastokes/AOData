function X = makeLEDStimulusFile(fName, X, ledObj)
    % MAKELEDSTIMULUSFILE
    %
    % Syntax:
    %   X = makeLEDStimulusFile(fName, X);
    %
    % Inputs:
    %   fName                       char
    %       File name (ending with .txt). If a full file path isn't
    %       specified, the file will save in cd
    %   X                           [N x 3]
    %       LED powers at each time point (default is every 2 ms)
    %   ledObj                      sara.calibrations.MaxwellianView
    %       Optional, used to get accurate LUT file names
    %
    % History:
    %   08Dec2021 - SSP
    %   03Nov2022 - SSP - Added calibration obj for LUT file names
    % ---------------------------------------------------------------------
    if nargin < 3
        ledObj = [];
    else
        assert(isa(ledObj, 'sara.calibrations.MaxwellianView'));
    end

    if size(X, 2) == 1
        X = [X, X, X];
    end
    if size(X, 1) == 3
        X = X';
    end
    assert(size(X, 2) == 3, 'X must be an [N x 3] matrix!');
    assert(endsWith(fName, '.txt'), 'fName must end with .txt!');

    % Open and discard existing contents
    fid = fopen(fName, 'w');
    % Make sure the file actually existed
    if fid == -1
        error('File %u could not be opened!', fName);
    end
    
    % Write the stimulus metadata
    fprintf(fid, '[header]\r\n');
    fprintf(fid, 'functionality    = 1\r\n');
    
    if isempty(ledObj)
        fprintf(fid, 'lut1 		= F:\\FunctionalImaging\\ExperimentParameters\\LUTs\\LUT_660nm_20230313_1ndf.txt\r\n');
        fprintf(fid, 'lut2 		= F:\\FunctionalImaging\\ExperimentParameters\\LUTs\\LUT_530nm_20220313_1ndf.txt\r\n');
        fprintf(fid, 'lut3 		= F:\\FunctionalImaging\\ExperimentParameters\\LUTs\\LUT_420nm_20220313_1ndf.txt\r\n');
    else
        fprintf(fid, 'lut1 		= F:\\FunctionalImaging\\ExperimentParameters\\LUTs\\%s.txt\r\n', ledObj.files('LUT1'));
        fprintf(fid, 'lut2 		= F:\\FunctionalImaging\\ExperimentParameters\\LUTs\\%s.txt\r\n', ledObj.files('LUT2'));
        fprintf(fid, 'lut3 		= F:\\FunctionalImaging\\ExperimentParameters\\LUTs\\%s.txt\r\n', ledObj.files('LUT3'));
    end
        

    fprintf(fid, 'interval_value	= 2\r\n');
    fprintf(fid, 'interval_unit	= ms\r\n');
    fprintf(fid, ['data_len	=', num2str(size(X, 1)) '\r\n']);

    % Write the stimulus data
    fprintf(fid, '\r\n');
    fprintf(fid, '[data]\r\n');
    for i = 1:size(X, 1)
        fprintf(fid, '%u=%.4f,%.4f,%.4f\r\n', i, X(i, 1), X(i, 2), X(i, 3));
    end

    fclose(fid);

    % Report to the command line
    fprintf('Completed %s\\%s\n', cd, fName);