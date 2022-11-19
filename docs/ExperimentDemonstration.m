
aoFolder = normPath('C:\Users\sarap\Dropbox\Postdoc\Code\AOData\');
experiment = aod.core.Experiment('DemoExperiment', aoFolder, '20220825');
experiment.setDescription('AOData demonstration');

% Create a system
system = aod.core.System('Fluorescence', 'DataFolderName', 'Vis'); 
% Add a parameter (written as an attribute of the system's HDF5 group)
system.addParam('LastAlignment', '20220908');
experiment.add(system);

% Create a channel and associated devices
channel = aod.core.Channel('Fluorescence');
system.add(channel);

% Add devices
channel.add(aod.builtin.devices.PMT('VisiblePMT',...
    'Manufacturer', 'Hamamatsu', 'Model', 'H16722'));
channel.add(aod.builtin.devices.LightSource(561,...
    'Manufacturer', 'Toptica', 'Model', 'iChrome MLE'));
channel.add(aod.builtin.devices.BandpassFilter(607, 70,...
    'Manufacturer', 'Semrock', 'Model', 'FF01-607_70'));
channel.add(aod.builtin.devices.Pinhole(20,...
    'Manufacturer', 'ThorLabs', 'Model', 'P20K'));
