function summarizePackageCoverage()
% Summarize AOData package code coverage
%
% Syntax:
%   summarizePackageCoverage()
%

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    [coverageTable, detailTable] = test.readCoverageReport(...
        fullfile(aotest.util.getAODataTestFolder(), 'coverage_report'));
    % Summarize the results by package
    packageNames = ["+api", "+app", "+builtin", "+core", "+infra", "+h5",...
        "+persistent", "+util"];

    packageCoverage = struct();
    for i = 1:numel(packageNames)
        idx = startsWith(detailTable.Name, packageNames(i));
        stmt = [sum(detailTable.StatementExec(idx)), sum(detailTable.StatementAll(idx))];
        fcn = [sum(detailTable.FunctionExec(idx)), sum(detailTable.FunctionAll(idx))];
        packageCoverage.(erase(packageNames(i), "+")) = [...
            stmt, round(100*stmt(1)/stmt(2),2), fcn, round(100*fcn(1)/fcn(2),2)]';
    end


    packageTable = struct2table(packageCoverage);
    packageTable.Total = [coverageTable{1,[2,1,4]}, coverageTable{2,[2,1,4]}]';
    packageTable.Properties.RowNames = [...
        "ExecutedStatements", "TotalStatements", "StatementCoverage",...
        "ExecutedFunctions", "TotalFunctions", "FunctionCoverage"];
    writetable(packageTable,...
        fullfile(aotest.util.getAODataTestFolder(), 'PackageCoverage.txt'),...
        'WriteRowNames', true);
    % Code coverage without app package
    baseCode = packageTable.Total - packageTable.app;
    fprintf('BaseCoverage = %u of %u statements (%.2f%%), %u of %u functions (%.2f%%)\n',...
        baseCode(1), baseCode(2), round(baseCode(1)/baseCode(2)*100,2),...
        baseCode(4), baseCode(5), round(baseCode(4)/baseCode(5)*100,2));