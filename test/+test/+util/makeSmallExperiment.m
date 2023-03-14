function pEXPT = makeSmallExperiment(writeToHdf, writeToMat)

    % Make a small experiment with missing entity types
    testDir = test.util.getAODataTestFolder();

    expt = aod.core.Experiment('SmallExperiment', testDir, getDateYMD());
    if writeToHdf
        aod.h5.writeExperimentToFile( ...
            fullfile(testDir, 'SmallExperiment.h5'), expt, true);
    end
    pEXPT = loadExperiment(fullfile(testDir, 'SmallExperiment.h5'));