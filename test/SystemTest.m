
resourceDir = '/Users/sarap/Dropbox/Postdoc/Code/ao-data-tools/packages/+sara/+resources';


system = aod.core.System([], 'SpectralPhysiology');

mustangChannel = aod.core.Channel(system);
mustangChannel.setDataFolder('Vis');
mustangChannel.addDevice(aod.builtin.devices.Pinhole([], 25,...
    'Manufacturer', 'ThorLabs', 'Model', 'P20K'));
mustangChannel.addDevice(aod.builtin.devices.PMT([], 'Gain', 0.805,...
    'Manufacturer', 'Hamamatsu', 'Model', 'H16722'));
mustangChannel.addDevice(aod.builtin.devices.LightSource([], 488,...
    'Manufacturer', 'Qioptiq'));
mustangChannel.addDevice(aod.builtin.devices.BandpassFilter([], 520, 35));
system.addChannel(mustangChannel);

ledChannel = aod.core.Channel(system);
% Add the LEDs
ledChannel.addDevice(aod.builtin.devices.LightSource([], 660,...
    'Manufacturer', 'ThorLabs', 'Model', 'M660L4'));
ledChannel.addDevice(aod.builtin.devices.LightSource([], 530,...
    'Manufacturer', 'ThorLabs', 'Model', 'M530L4'));
ledChannel.addDevice(aod.builtin.devices.LightSource([], 415,...
    'Manufacturer', 'ThorLabs', 'Model', 'M415L4'));
% Add the neutral density filter
ndf10 = aod.builtin.devices.NeutralDensityFilter([], 1.0,...
    'Manufacturer', 'ThorLabs', 'Model', 'NE10A-A');
ndf10.setTransmission(dlmread(fullfile(resourceDir, 'NE10A.txt')));
ledChannel.addDevice(ndf10);
% Add the dichroic filters
ff470 = aod.builtin.devices.DichroicFilter([], 470,...
    'Manufacturer', 'Semrock', 'Model', 'FF47-Di01');
ff470.setSpectrum(dlmread(fullfile(resourceDir, 'FF470_Di01.txt')));
ledChannel.addDevice(ff470);
ff562 = aod.builtin.devices.DichroicFilter([], 562,...
    'Manufacturer', 'Semrock', 'Model', 'FF562_Di03');
ff562.setSpectrum(dlmread(fullfile(resourceDir, 'FF562_Di03.txt')));
ledChannel.addDevice(ff562);
ff649 = aod.builtin.devices.DichroicFilter([], 649,...
    'Manufacturer', 'Semrock', 'Model', 'FF649-Di01');
ff649.setSpectrum(dlmread(fullfile(resourceDir, 'FF649_Di01.txt')));
ledChannel.addDevice(ff649);
system.addChannel(ledChannel);

reflectanceChannel = aod.core.Channel(system);
reflectanceChannel.addDevice(aod.builtin.devices.LightSource([], 796,...
    'Manufacturer', 'SuperLum'));

wavefrontChannel = aod.core.Channel(system);
wavefrontChannel.addDevice(aod.builtin.devices.LightSource([], 847,...
    'Model', 'QPhotonics'));
