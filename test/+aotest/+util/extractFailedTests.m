function failed = extractFailedTests(results)
% Extract just the failed TestResult information
%
% Syntax:
%   failed = aotest.util.extractFailedTests(results)
%
% Inputs:
%   results             matlab.unittest.TestResult
%
% Outputs:
%   failed              matlab.unittest.TestResult

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    arguments
        results         matlab.unittest.TestResult
    end

    idx = arrayfun(@(x) x.Failed | x.Incomplete, results);
    failed = results(idx);

