% CORECLASSINSTANTIATION
% - Confirm core classes can be instantiated
% --

import aod.core.*

calibration = Calibration([], '20220822'); %#ok<*NASGU> 

source = Source('SourceName');
source.addSource(Source('SubSourceName'));

system = System([], 'SystemName');
channel = Channel([], 'ChannelName');
device = Device([], 'Model', 'P20K', 'Manufacturer', 'ThorLabs');

stimulus = Stimulus([]);
registration = aod.builtin.registrations.RigidRegistration([], eye(3));
dataset = Dataset([], 'DatasetName');
response = Response([]);
timing = aod.core.timing.TimeStamps(response, 1:4);

analysis = Analysis([], 'AnalysisName');

clear source calibration system channel device stimulus response registration analysis
clear('import');