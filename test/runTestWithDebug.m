function results = runTestWithDebug(testName, coveragePackage)
% Run test with debugging and optional code coverage
%
% Syntax:
%   results = runTestWithDebug(testName);
%   results = runTestWithDebug(testName, coveragePackage);

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    import matlab.unittest.plugins.StopOnFailuresPlugin
    import matlab.unittest.plugins.CodeCoveragePlugin
    import matlab.unittest.plugins.codecoverage.CoverageReport    
    
    % Delete pre-existing test HDF5 files, if necessary
    test.util.deleteTestFiles();

    % Run the suite in this function's directory ('test')
    if ~ispref('AOData', 'BasePackage')
        setpref('AOData', 'BasePackage',...
            [fileparts(fileparts(mfilename('fullpath'))), filesep]);
    end
    currentCD = pwd();
    cd(fileparts(mfilename('fullpath')));

    % Create the test suite and runner
    suite = testsuite(testName);
    runner = testrunner("textoutput");

    % Debugging plugin
    runner.addPlugin(StopOnFailuresPlugin);

    % Code coverage plugin
    if nargin == 2
        if ~exist('single_report', 'dir')
            mkdir('single_report');
        end
        p = CodeCoveragePlugin.forPackage(coveragePackage,...
            'IncludingSubpackages', true,...
            'Producing', CoverageReport(fullfile(pwd, 'single_report')));
        runner.addPlugin(p);
    end

    results = runner.run(suite);

    % Clean up files produced by tests, if necessary
    test.util.deleteTestFiles();

    if nargin == 2    
        open(fullfile('single_report', 'index.html'));
    end 

    % Return to user's previous working directory
    cd(currentCD);

