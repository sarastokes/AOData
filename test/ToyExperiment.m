function experiment = ToyExperiment(writeToHDF)
% Create a toy experiment for testing
%
% Description:
%   Builds a quick experiment to serve as a basis for testing
%
% Syntax:
%   experiment = ToyExperiment(writeToHDF)
%
% Inputs:
%   writeToHDF          logical (default=false)
%       Whether to persist the experiment to an HDF5 file
%
% Output:
%   experiment          aod.core.Experiment
%
% Notes:
%   HDF file will write to current directory as 'ToyExperiment.h5'
    
% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    if nargin < 1
        writeToHDF = false;
    end

    experiment = aod.core.Experiment('Tester', cd, '20220823',...
        'Administrator', "Sara Patterson",...
        'Laboratory', "Primate-1P");

    experiment.setDescription('This is a test experiment');
    experiment.addNote('This is the first note');
    experiment.addNote('This is the second note');

    % Add a source
    source = sara.factories.SubjectFactory.create(851, 'OS', 'Right');
    experiment.add(source);

    % System
    system = aod.core.System('Base');
    [~, system] = sara.factories.ChannelFactory.create(...
        'MustangImaging', system, 'Pinhole', 25);
    [~, system] = sara.factories.ChannelFactory.create(...
        'ReflectanceImaging', system);
    [~, system] = sara.factories.ChannelFactory.create(...
        'WavefrontSensing', system);
    experiment.add(system);

    % Calibrations
    calibration1 = aod.builtin.calibrations.PowerMeasurement(...
        'Mustang', getDateYMD(), 488);
    calibration1.addMeasurement(24:26, 16:18);
    experiment.add(calibration1);

    calibration2 = aod.builtin.calibrations.ChannelOptimization([],...
        getDateYMD(), 'PMT', [6 7 8], 'Source', 3,...
        'Channel', experiment.get('Channel', {'Name', 'MustangImaging'}));
    experiment.add(calibration2);

    % Experiment Datasets
    dset1 = aod.core.ExperimentDataset('ExpDataset1',... 
        'Data', eye(3));
    experiment.add(dset1);

    % Epochs
    epoch = aod.core.Epoch(1, 'Source', source, 'System', system);
    epoch.setFile('PresyncFile', fullfile(cd, 'PresyncFile.txt'));
    experiment.add(epoch);
    epoch.setTiming(1:5);
    epoch.setFile('PostSyncFile', fullfile(cd, 'PostSyncFile.txt'));
    
    experiment.add(aod.core.Epoch(2, 'Source', source));
    setParam(experiment.Epochs, 'RefPmtGain', 0.51);

    % Registrations
    reg = aod.builtin.registrations.RigidRegistration('SIFT', '20220823', eye(3));
    epoch.add(reg);

    % Responses
    response1 = aod.core.Response('ResponseWithTiming');
    response1.setData(2:2:8);
    response1.setTiming(linspace(0.5, 2.5, 4));
    epoch.add(response1);

    response2 = aod.core.Response('ResponseWithoutTiming');
    response2.setData(2:2:8);
    epoch.add(response2);

    % Stimuli
    stim = aod.builtin.stimuli.ImagingLight('Mustang', 22,...
        'IntensityUnits', "Normalized");
    epoch.add(stim);

    % Datasets
    epoch.add(aod.core.EpochDataset('Dataset1', magic(5)));

    % Annotation
    experiment.add(aod.core.Annotation('Annotation1'));

    % Analysis
    experiment.add(aod.core.Analysis('TestAnalysis', 'Date', getDateYMD()));

    if writeToHDF
        fileName = fullfile(getpref('AOData', 'BasePackage'), 'test', 'ToyExperiment.h5');
        aod.h5.writeExperimentToFile(fileName, experiment, true);
    end