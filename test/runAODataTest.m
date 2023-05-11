function results = runAODataTest(testName, varargin)
% Run test with debugging and optional code coverage
%
% Syntax:
%   results = runAODataTest(testName);
%   results = runAODataTest(testName, 'Debug', true',...
%       'Package', 'aod.core', 'KeepFiles', false, 'ResetFiles', true);
%
% See also:
%   runAODataTestSuite, runtests

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    import matlab.unittest.plugins.StopOnFailuresPlugin
    import matlab.unittest.plugins.CodeCoveragePlugin
    import matlab.unittest.plugins.codecoverage.CoverageReport    

    ip = inputParser();
    ip.CaseSensitive = false;
    addParameter(ip, 'Package', [], @istext);
    addParameter(ip, 'Debug', false, @islogical);
    addParameter(ip, 'KeepFiles', false, @islogical);
    addParameter(ip, 'ResetFiles', true, @islogical);
    parse(ip, varargin{:});

    coveragePackage = ip.Results.Package;
    debugFlag = ip.Results.Debug;
    resetFiles = ip.Results.ResetFiles;
    keepFiles = ip.Results.KeepFiles;
    
    % Delete pre-existing test HDF5 files, if necessary
    if resetFiles
        test.util.deleteTestFiles();
    end

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

    setpref('AOData', 'TestMode', true);
    results = runner.run(suite);
    setpref('AOData', 'TestMode', false);

    % Clean up files produced by tests, if necessary
    if ~keepFiles
        test.util.deleteTestFiles();
    end

    if nargin > 1 && ~isempty(coveragePackage)
        open(fullfile('single_report', 'index.html'));
    end 

    % Return to user's previous working directory
    cd(currentCD);

