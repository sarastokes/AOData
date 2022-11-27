function makeTestTextFile(outputDir, fileName)
    % MAKETESTTEXTFILE
    %
    % Description:
    %   Makes a test text file with accurate file paths 
    %
    % Syntax:
    %   makeTestTextFile()
    %   makeTestTextFile(outputDir, fileName)
    %
    % Optional inputs:
    %   outputDir           char (default = test_data directory)
    %       The folder to save the text file
    %   fileName            char (default = 'test.txt')
    %       The name of the output text file, must end in .txt
    % ---------------------------------------------------------------------
    arguments
        outputDir           char = []
        fileName            char = []
    end

    if isempty(outputDir)
        outputDir = fullfile(getpref('AOData', 'BasePackage'), 'test', 'test_data');
    else
        assert(isfolder(outputDir), 'Folder path must be valid')
    end
    if isempty(fileName)
        fileName = 'test.txt';
    else
        assert(endsWith('.txt'), 'File name must end with .txt');
    end

    % Open and discard existing contents
    fid = fopen(fullfile(outputDir, fileName), 'w');

    % Write some parameters
    fprintf(fid, 'PMTGain = 0.541\r\n');
    fprintf(fid, 'FieldOfView = 3.69, 2.70\r\n')
    fprintf(fid, 'Video = %s\r\n', fullfile(outputDir, 'test.avi'));
    fprintf(fid, 'Stablization = yes\r\n');
    fprintf(fid, 'TfProperty = true\r\n');

    % Close and report out success
    fclose(fid);
    fprintf('Wrote %s\n', fullfile(outputDir, fileName));