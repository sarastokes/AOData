function verifyDatetimesEqual(testCase, actual, expected)
% Check whether each component of datetime is equal
%
% Syntax:
%   aotest.util.verifyDatetimesEqual(testCase, actual, expected)
%
% See also:
%   aotest.util.verifyDatesEqual

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    testCase.verifyEqual(actual.Year, expected.Year);
    testCase.verifyEqual(actual.Month, expected.Month);
    testCase.verifyEqual(actual.Day, expected.Day);
    testCase.verifyEqual(actual.Hour, expected.Hour);
    testCase.verifyEqual(actual.Minute, expected.Minute);
    testCase.verifyEqual(actual.Second, expected.Second);
    testCase.verifyEqual(actual.TimeZone, expected.TimeZone);
