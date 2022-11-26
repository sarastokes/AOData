function verifyDatesEqual(testCase, actual, expected)
    % VERIFYDATESEQUAL
    %
    % Syntax:
    %   verifyDatesEqual(testCase, actual, expected)
    % ---------------------------------------------------------------------
    
    testCase.verifyEqual(actual.Year, expected.Year);
    testCase.verifyEqual(actual.Month, expected.Month);
    testCase.verifyEqual(actual.Day, expected.Day);
