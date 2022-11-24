function results = runAODataTestSuite(varargin)
    % RUNAODATATESTSUITE
    %
    % Description:
    %   Runs the full AOData test suite with optional code coverage report
    %
    % Syntax:
    %   results = runAODataTestSuite()
    %   results = runAODataTestSuite('Coverage', tf, 'KeepFiles', tf)
    %
    % Optional key/value inputs:
    %   Coverage            logical (default = false)
    %       Whether to output coverage report
    %   KeepFiles           logical (default = false)
    %       Whether to keep HDF5 files produced by the test suite
    % ---------------------------------------------------------------------
    
    ip = inputParser();
    addParameter(ip, 'Coverage', false, @islogical);
    addParameter(ip, 'KeepFiles', false, @islogical);
    addParameter(ip, 'Debug', false, @islogical);
    parse(ip, varargin{:});

    coverageFlag = ip.Results.Coverage;
    fileFlag = ip.Results.KeepFiles;

    % Initialization
    if ~ispref('AOData', 'BasePackage')
        setpref('AOData', 'BasePackage',...
            [fileparts(fileparts(mfilename('fullpath'))), filesep]);
    end
    currentCD = pwd();

    % Run the suite in this function's directory ('test')
    cd(fileparts(mfilename('fullpath')));

    if coverageFlag
        results = testWithCoverageReport();
    else
        results = testWithoutCoverageReport();
    end

    % Clean up test files
    if ~fileFlag
        delete('test.h5');
        delete('HdfTest.h5');
    end

    % Return to user's previous working directory
    cd(currentCD);
end

function results = testWithoutCoverageReport(debugFlag)
    if debugFlag
        import matlab.unittest.plugins.StopOnFailuresPlugin
    end
    results = runtests();
end

function results = testWithCoverageReport(debugFlag)
    import matlab.unittest.plugins.CodeCoveragePlugin
    import matlab.unittest.plugins.codecoverage.CoverageReport
    
    if debugFlag
        import matlab.unittest.plugins.StopOnFailuresPlugin
    end
    
    flag = exist('coverage_report', 'dir');
    if flag == 0
        mkdir('coverage_report');
    end

    suite = testsuite(pwd);
    runner = testrunner("textoutput");

    p = CodeCoveragePlugin.forPackage("aod",...
        'IncludingSubpackages', true,...
        'Producing', CoverageReport(fullfile(pwd, 'coverage_report')));
    runner.addPlugin(p);
    results = runner.run(suite);
    open(fullfile('coverage_report', 'index.html'));
end