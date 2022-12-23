function verifyDatesEqual(testCase, actual, expected)
% Check whether the dates in datetime are equal
%
% Description:
%   Checks whether year, month and date in datetimes are equal
%
% Syntax:
%   test.util.verifyDatesEqual(testCase, actual, expected)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------
    
    testCase.verifyEqual(actual.Year, expected.Year);
    testCase.verifyEqual(actual.Month, expected.Month);
    testCase.verifyEqual(actual.Day, expected.Day);
