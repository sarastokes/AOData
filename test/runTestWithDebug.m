function results = runTestWithDebug(testName, coveragePackage, debugFlag)
% Run test with debugging and optional code coverage
%
% Syntax:
%   results = runTestWithDebug(testName);
%   results = runTestWithDebug(testName, coveragePackage, debugFlag);
%
% Example:
%   results = runTestWithDebug('FilterTest', 'aod.api', true);
%
% See also:
%   runAODataTestSuite, runtests

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    if nargin < 2
        coveragePackage = [];
    end

    if nargin < 3
        debugFlag = true;
    end

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
    if debugFlag
        runner.addPlugin(StopOnFailuresPlugin);
    end

    % Code coverage plugin
    if nargin > 1 && ~isempty(coveragePackage)
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

    if nargin > 1 && ~isempty(coveragePackage)
        open(fullfile('single_report', 'index.html'));
    end 

    % Return to user's previous working directory
    cd(currentCD);

