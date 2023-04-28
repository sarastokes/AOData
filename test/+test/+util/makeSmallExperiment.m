function pEXPT = makeSmallExperiment(writeToHdf, fileName)
% Make a small experiment to support later modification in testing
%
% Syntax:
%   aod.util.test.makeSmallExperiment(writeToHdf)
%   pEXPT = aod.util.test.makeSmallExperiment(writeToHdf, fileName)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    if nargin < 2
        fileName = 'SmallExperiment.h5';
    end

    % Make a small experiment with missing entity types
    testDir = test.util.getAODataTestFolder();

    expt = aod.core.Experiment('SmallExperiment', testDir, getDateYMD());
    if writeToHdf
        aod.h5.writeExperimentToFile( ...
            fullfile(testDir, fileName), expt, true);
    end

    if nargout > 0
        pEXPT = loadExperiment(fullfile(testDir, fileName));
    end