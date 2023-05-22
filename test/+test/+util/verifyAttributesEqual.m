function verifyAttributesEqual(testCase, actual, expected)
% Check whether aod.common.Attributes are equal
%
% Syntax:
%   test.util.verifyAttributesEqual(testCase, actual, expected)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    testCase.verifyClass(actual, 'aod.common.Attributes');

    testCase.verifyEqual(expected.Count, actual.Count)

    k = expected.keys;
    for i = 1:numel(k)
        testCase.verifyTrue(actual.isKey(k{i}));
        testCase.verifyEqual(actual(k{i}), expected(k{i}));
    end

