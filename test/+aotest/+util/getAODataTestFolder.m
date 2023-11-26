function testPath = getAODataTestFolder()
% Convenience function to find AOData's test folder
%
% Syntax:
%   testPath = aotest.util.getAODataTestFolder()

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    testPath = fullfile(getpref('AOData', 'BasePackage'), 'test');

