function verifyDatesEqual(testCase, actual, expected)
    % VERIFYDATESEQUAL
    %
    % Syntax:
    %   verifyDatesEqual(testCase, actual, expected)
    % ---------------------------------------------------------------------
    
    testCase.verifyEqual(actual.Year, expected.Year);
    testCase.verifyEqual(actual.Month, expected.Month);
    testCase.verifyEqual(actual.Day, expected.Day);
    testCase.verifyEqual(actual.Hour, expected.Hour);
    testCase.verifyEqual(actual.Minute, expected.Minute);
    testCase.verifyEqual(actual.Second, expected.Second);
    testCase.verifyEqual(actual.TimeZone, expected.TimeZone);
