function out = readCoverageReport(coverageFolder)
% Reads the summary table from coverage report 
%
% Description:
%   Reads in OverallCoverageData.js as text and extracts out the summary 
%   data for statement and function coverage.
%
% Syntax:
%   out = readCoverageReport(fileName)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    arguments
        coverageFolder        {mustBeFolder}
    end

    fileName = fullfile(coverageFolder, 'release', 'coverageData', 'OverallCoverageData.js');

    fid = fopen(fileName);
    if fid == -1
        error('readCoverageReport:FileNotFound',...
            'Could not find file %s', fileName);
    end

    % The entire contents are in the first line
    tline = fgetl(fid);

    % Extract out summary data for statement and function coverage
    totalLines = cellfun(@str2double, extractBetween(tline, '"Total":', ','));
    executedLines = cellfun(@str2double, extractBetween(tline, '"Executed":', ','));
    missedLines = cellfun(@str2double, extractBetween(tline, '"Missed":', ','));
    pctCoverage = cellfun(@str2double, extractBetween(tline, '"PercentCoverage":', '}'));

    out = table(totalLines, executedLines, missedLines, pctCoverage, ...
        'RowNames', {'Statement', 'Function'},...
        'VariableNames', {'Total', 'Executed', 'Missed', 'PercentCoverage'});

    fclose(fid);