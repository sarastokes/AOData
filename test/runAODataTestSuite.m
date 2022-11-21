function results = runAODataTestSuite()
    % RUNAODATATESTSUITE
    %
    % Description:
    %   Runs the full AOData test suite
    %
    % Syntax:
    %   results = runAODataTestSuite()
    % ---------------------------------------------------------------------
    
    % Initialization
    if ~ispref('AOData', 'BasePackage')
        setpref('AOData', 'BasePackage',...
            [fileparts(fileparts(mfilename('fullpath'))), filesep]);
    end
    currentCD = pwd();

    % Run the suite in this function's directory ('test')
    cd(fileparts(mfilename('fullpath')));
    results = runtests();
    % Clean up test files
    delete('test.h5');

    % Return to user's previous working directory
    cd(currentCD);
