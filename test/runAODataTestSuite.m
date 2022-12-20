function [results, packageTable] = runAODataTestSuite(varargin)
% RUNAODATATESTSUITE
%
% Description:
%   Runs the full test suite with options for code coverage reports, 
%   debugging and keeping files produced during testing
%
% Syntax:
%   results = runAODataTestSuite()
%   results = runAODataTestSuite(varargin)
%   [results, coverageTable] = runAODataTestSuite('Coverage', false);
%
% Optional key/value inputs:
%   Coverage            logical (default = false)
%       Whether to output coverage report
%   KeepFiles           logical (default = false)
%       Whether to keep HDF5 files produced by the test suite
%   Debug               logical (default = false)
%       Whether to stop on failures
%
% Outputs:
%   results             matlab.unittest.TestResult
%       The results of each test case
%   coverageTable       table
%       A table containing the statement/function coverage summary, 
%       empty if the Coverage parameter was false.

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    
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

    % Delete pre-existing test HDF5 files, if necessary
    test.util.deleteTestFiles();

    % Run the test suite
    if coverageFlag
        results = testWithCoverageReport(debugFlag);
        [coverageTable, detailTable] = test.readCoverageReport(fullfile(pwd, 'coverage_report'));
        % Summarize the results by package
        packageNames = ["+api", "+app", "+builtin", "+core", "+h5", "+persistent", "+util"];
        packageCoverage = struct();
        for i = 1:numel(packageNames)
            idx = startsWith(detailTable.Name, packageNames(i));
            stmt = [sum(detailTable.StatementExec(idx)), sum(detailTable.StatementAll(idx))];
            fcn = [sum(detailTable.FunctionExec(idx)), sum(detailTable.FunctionAll(idx))];
            packageCoverage.(erase(packageNames(i), "+")) = [...
                stmt, 100*stmt(1)/stmt(2), fcn, 100*fcn(1)/fcn(2)]';
        end
        packageTable = struct2table(packageCoverage);
        packageTable.Total = [coverageTable{1,[2,1,4]}, coverageTable{2,[2,1,4]}]';
        packageTable.Properties.RowNames = [...
            "ExecutedStatements", "TotalStatements", "StatementCoverage",... 
            "ExecutedFunctions", "TotalFunctions", "FunctionCoverage"];
    else
        results = testWithoutCoverageReport(debugFlag);
        packageTable = [];
    end

    % Clean up files produced by tests, if necessary
    if ~fileFlag
        test.util.deleteTestFiles();
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
    
    if ~exist('coverage_report', 'dir')
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