function results = runAODataTestSuite(varargin)
    % RUNAODATATESTSUITE
    %
    % Description:
    %   Runs the full AOData test suite with optional code coverage report
    %
    % Syntax:
    %   results = runAODataTestSuite()
    %   results = runAODataTestSuite(varargin)
    %
    % Optional key/value inputs:
    %   Coverage            logical (default = false)
    %       Whether to output coverage report
    %   KeepFiles           logical (default = false)
    %       Whether to keep HDF5 files produced by the test suite
    %   Debug               logical (default = false)
    %       Whether to stop on failures
    % ---------------------------------------------------------------------
    
    ip = inputParser();
    addParameter(ip, 'Coverage', false, @islogical);
    addParameter(ip, 'KeepFiles', false, @islogical);
    addParameter(ip, 'Debug', false, @islogical);
    parse(ip, varargin{:});

    coverageFlag = ip.Results.Coverage;
    fileFlag = ip.Results.KeepFiles;
    debugFlag = ip.Results.Debug;

    % Initialization
    if ~ispref('AOData', 'BasePackage')
        setpref('AOData', 'BasePackage',...
            [fileparts(fileparts(mfilename('fullpath'))), filesep]);
    end
    currentCD = pwd();

    % Run the suite in this function's directory ('test')
    cd(fileparts(mfilename('fullpath')));

    if coverageFlag
        results = testWithCoverageReport(debugFlag);
    else
        results = testWithoutCoverageReport(debugFlag);
    end

    % Clean up test files
    if ~fileFlag
        delete('ToyExperiment.h5');
        delete('HdfTest.h5');
    end

    % Return to user's previous working directory
    cd(currentCD);
end

function results = testWithoutCoverageReport(debugFlag)
    import matlab.unittest.plugins.StopOnFailuresPlugin
    suite = testsuite(pwd);
    runner = testrunner("textoutput");
    if debugFlag
        runner.addPlugin(StopOnFailuresPlugin);
    end
    results = runner.run(suite);
end

function results = testWithCoverageReport(debugFlag)
    import matlab.unittest.plugins.CodeCoveragePlugin
    import matlab.unittest.plugins.codecoverage.CoverageReport    
    import matlab.unittest.plugins.StopOnFailuresPlugin
    
    flag = exist('coverage_report', 'dir');
    if flag == 0
        mkdir('coverage_report');
    end

    suite = testsuite(pwd);
    runner = testrunner("textoutput");
    if debugFlag
        runner.addPlugin(StopOnFailuresPlugin);
    end

    p = CodeCoveragePlugin.forPackage("aod",...
        'IncludingSubpackages', true,...
        'Producing', CoverageReport(fullfile(pwd, 'coverage_report')));
    runner.addPlugin(p);
    results = runner.run(suite);
    open(fullfile('coverage_report', 'index.html'));
end