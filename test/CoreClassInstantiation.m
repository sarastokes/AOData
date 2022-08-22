% CORECLASSINSTANTIATION
% - Confirm core classes can be instantiated
% --

import aod.core.*

calibration = Calibration([], '20220822'); %#ok<*NASGU> 

source = Source([], 'SourceName');
system = System([], 'SystemName');
channel = Channel([], 'ChannelName');
device = Device([], 'Model', 'P20K', 'Manufacturer', 'ThorLabs');

stimulus = Stimulus([]);
response = Response([]);
registration = aod.builtin.registrations.RigidRegistration([], eye(3));
dataset = Dataset([], 'DatasetName');

analysis = Analysis([]);

clear source calibration system channel device stimulus response registration analysis
clear import