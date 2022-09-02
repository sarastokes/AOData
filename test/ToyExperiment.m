function experiment = ToyExperiment(writeToHDF)
    % TOYEXPERIMENT
    %
    % Description:
    %   Builds a quick experiment to serve as a basis for testing
    %
    % Syntax:
    %   experiment = ToyExperiment(writeToHDF)
    % ---------------------------------------------------------------------

    if nargin < 1
        writeToHDF = false;
    end

    experiment = aod.core.Experiment('Tester', cd, '20220823',...
        'Administrator', 'Sara Patterson');

    source = sara.factories.SubjectFactory.create(851, 'OS', 'Right');
    experiment.addSource(source);

    % Add the system(s)
    system = aod.core.System('SpectralPhysiology');
    system = sara.factories.ChannelFactory.create(...
        'MaxwellianView', system, 'NDF', 1.0);
    system = sara.factories.ChannelFactory.create(...
        'MustangImaging', system, 'Pinhole', 25);
    system = sara.factories.ChannelFactory.create(...
        'ReflectanceImaging', system);
    system = sara.factories.ChannelFactory.create(...
        'WavefrontSensing', system);
    experiment.addSystem(system);

    calibration = sara.calibrations.MustangPower('20220823');
    calibration.addMeasurement(24:26, 16:18);
    experiment.addCalibration(calibration);

    epoch = aod.core.Epoch(1, 'Source', source.Sources(1).Sources(1), 'System', system);
    epoch.setFile('PresyncFile', fullfile(cd, 'PresyncFile.txt'));
    experiment.addEpoch(epoch);
    epoch.setTiming(1:5);
    epoch.setFile('PostSyncFile', fullfile(cd, 'PostSyncFile.txt'));

    experiment.addNote('This is the first note');
    experiment.addNote('This is the second note');
    experiment.setDescription('This is a test experiment');

    reg = aod.builtin.registrations.RigidRegistration('SIFT', '20220823', eye(3));
    epoch.addRegistration(reg);

    response1 = aod.core.Response('ResponseWithTiming');
    response1.setData(2:2:8);
    response1.setTiming(linspace(0.5, 2.5, 4));
    epoch.addResponse(response1);

    response2 = aod.core.Response('ResponseWithoutTiming');
    response2.setData(2:2:8);
    epoch.addResponse(response2);

    if writeToHDF
        aod.h5.writeExperimentToFile('test.h5', experiment, true);
    end