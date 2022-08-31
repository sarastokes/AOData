
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
calibration.addMeasurement([24:26], [16:18]);
experiment.addCalibration(calibration);

epoch = aod.core.Epoch(2, 'Source', source.Sources(1).Sources(1), 'System', system);
experiment.addEpoch(epoch);
epoch.setTiming(1:5);

experiment.addNote('This is the first note');
experiment.addNote('This is the second note');
experiment.addDescription('This is a test experiment');

reg = aod.builtin.registrations.RigidRegistration('SIFT', '20220823', eye(3));
epoch.addRegistration(reg);

response1 = aod.core.Response('ResponseWithTiming');
response1.setData(2:2:8);
response2.setTiming(linspace(0.5, 2.5, 4));
response2 = aod.core.Response('ResponseWithoutTiming');
response2.setData(2:2:8);

epoch.addResponse(response1);
epoch.addResponse(response2);
epoch.setFile('Vis', fullfile(cd, 'AO'));

aod.h5.writeExperimentToFile('test.h5', experiment, true);