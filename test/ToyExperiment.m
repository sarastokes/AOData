function experiment = ToyExperiment(writeToHDF)
    % TOYEXPERIMENT
    %
    % Description:
    %   Builds a quick experiment to serve as a basis for testing
    %
    % Syntax:
    %   experiment = ToyExperiment(writeToHDF)
    %
    % Notes:
    %   HDF file will write to current directory
    % ---------------------------------------------------------------------

    if nargin < 1
        writeToHDF = false;
    end

    experiment = aod.core.Experiment('Tester', cd, '20220823',...
        'Administrator', 'Sara Patterson',...
        'Laboratory', 'Primate-1P');

    experiment.setDescription('This is a test experiment');
    experiment.addNote('This is the first note');
    experiment.addNote('This is the second note');

    % Add a source
    source = sara.factories.SubjectFactory.create(851, 'OS', 'Right');
    experiment.add(source);

    % Add the system(s)
    system = aod.core.System('SpectralPhysiology');
    [~, system] = sara.factories.ChannelFactory.create(...
        'MaxwellianView', system, 'NDF', 1.0);
    [~, system] = sara.factories.ChannelFactory.create(...
        'MustangImaging', system, 'Pinhole', 25);
    [~, system] = sara.factories.ChannelFactory.create(...
        'ReflectanceImaging', system);
    [~, system] = sara.factories.ChannelFactory.create(...
        'WavefrontSensing', system);
    experiment.add(system);

    calibration1 = aod.builtin.calibrations.PowerMeasurement(...
        'Mustang', getDateYMD(), 488);
    calibration1.addMeasurement(24:26, 16:18);
    experiment.add(calibration1);

    calibration2 = aod.builtin.calibrations.Optimization([],...
        getDateYMD(), 'xPMT', 6, 'yPMT', 7, 'zPMT', 8, 'SourcePosition', 3);
    experiment.add(calibration2);

    epoch = aod.core.Epoch(1, 'Source', source, 'System', system);
    epoch.setFile('PresyncFile', fullfile(cd, 'PresyncFile.txt'));
    experiment.add(epoch);
    epoch.setTiming(1:5);
    epoch.setFile('PostSyncFile', fullfile(cd, 'PostSyncFile.txt'));

    reg = aod.builtin.registrations.RigidRegistration('SIFT', '20220823', eye(3));
    epoch.add(reg);

    response1 = aod.core.Response('ResponseWithTiming');
    response1.setData(2:2:8);
    response1.setTiming(linspace(0.5, 2.5, 4));
    epoch.add(response1);

    response2 = aod.core.Response('ResponseWithoutTiming');
    response2.setData(2:2:8);
    epoch.add(response2);

    stim = aod.builtin.stimuli.ImagingLight('Mustang', 22, 'Normalized');
    epoch.add(stim);

    experiment.add(aod.core.Epoch(2, 'Source', source));

    setParam(experiment.Epochs, 'RefPmtGain', 0.51);

    experiment.add(aod.core.Analysis('TestAnalysis', 'Date', getDateYMD()));

    if writeToHDF
        fileName = fullfile(getpref('AOData', 'BasePackage'), 'test', 'ToyExperiment.h5');
        aod.h5.writeExperimentToFile(fileName, experiment, true);
    end