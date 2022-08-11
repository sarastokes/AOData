classdef ChannelFactory < aod.core.Factory

    methods
        function obj = ChannelFactory()
            % Do nothing
        end

        function channel = get(obj, channelName) %#ok<INUSL> 
            switch channelName 
                case 'Reflectance'
                    channel = aod.core.Channel(system);
                    channel.addDevice(aod.builtin.devices.LightSource([], 796,...
                        'Manufacturer', 'SuperLum'));
                    channel.setDataFolder('Ref');
                case 'Wavefront'
                    channel = aod.core.Channel(system);
                    channel.addDevice(aod.builtin.devices.LightSource([], 847,...
                        'Manufacturer', 'QPhotonics'));
                case 'MustangImaging'
                    channel = aod.core.Channel(system);
                    channel.setDataFolder('Vis');
                    channel.addDevice(aod.builtin.devices.Pinhole([], 25,...
                        'Manufacturer', 'ThorLabs', 'Model', 'P20K'));
                    channel.addDevice(aod.builtin.devices.PMT([], 'Gain', 0.805,...
                        'Manufacturer', 'Hamamatsu', 'Model', 'H16722'));
                    channel.addDevice(aod.builtin.devices.LightSource([], 488,...
                        'Manufacturer', 'Qioptiq'));
                    channel.addDevice(aod.builtin.devices.BandpassFilter([], 520, 35));
                    channel.setDataFolder('Vis');
                case 'MaxwellianView'
                    channel = aod.core.Channel();
                    % Add the LEDs
                    channel.addDevice(aod.builtin.devices.LightSource([], 660,...
                        'Manufacturer', 'ThorLabs', 'Model', 'M660L4'));
                    channel.addDevice(aod.builtin.devices.LightSource([], 530,...
                        'Manufacturer', 'ThorLabs', 'Model', 'M530L4'));
                    channel.addDevice(aod.builtin.devices.LightSource([], 415,...
                        'Manufacturer', 'ThorLabs', 'Model', 'M415L4'));
                    % Add the dichroic filters
                    ff470 = aod.builtin.devices.DichroicFilter([], 470,...
                        'Manufacturer', 'Semrock', 'Model', 'FF47-Di01');
                    ff470.setSpectrum(sara.resources.getResource('FF470_Di01.txt'));
                    channel.addDevice(ff470);
                    ff562 = aod.builtin.devices.DichroicFilter([], 562,...
                        'Manufacturer', 'Semrock', 'Model', 'FF562_Di03');
                    ff562.setSpectrum(sara.resources.getResource('FF562_Di03.txt'));
                    channel.addDevice(ff562);
                    ff649 = aod.builtin.devices.DichroicFilter([], 649,...
                        'Manufacturer', 'Semrock', 'Model', 'FF649-Di01');
                    ff649.setSpectrum(sara.resources.getResource('FF649_Di01.txt'));
                    channel.addDevice(ff649);
                otherwise
                    error('Unrecognized channel: %s', channelName);
            end
        end
    end
    
    methods (Static)
        function out = create(channelName, system)
            obj = sara.factories.ChannelFactory();
            channel = obj.get(channelName);
            if nargin > 1
                assert(isSubclass(system, 'aod.core.System'));
                system.addChannel(channel);
                out = system;
            else
                out = channel;
            end
        end

        function channel = addNDF(channel, attenuation)
            ndf = aod.builtin.devices.NeutralDensityFilter([], attenuation,...
                'Manufacturer', 'ThorLabs', 'Model', sprintf('NE%uA-A', 10*attenuation));
            ndf.setTransmission(sara.resources.loadResource(...
                sprintf('NE%uA.txt', 10*attenuation)));
            channel.addDevice(ndf);
        end

        function channel = addFilter(channel, filterName)
            switch filterName
                case '585_40'
                    filter = aod.builtin.devices.BandpassFilter([], 585, 40,...
                        'Manufacturer', 'Semrock', 'Model', 'FF01-585/40');
                    filter.setTransmission(sara.resources.getResource('FF01-585_40.txt'));
                case '590_20'
                    filter = aod.builtin.devices.BandpassFilter([], 590, 20,...
                        'Manufacturer', 'Semrock', 'Model', 'FF01-590/20');
                    filter.setTransmission(sara.resources.getResource('FF01-590_20.txt'));
                case '607_70'
                    filter = aod.builtin.devices.BandpassFilter([], 607, 70,...
                        'Manufacturer', 'Semrock', 'Model', 'FF01-670/20');
                    filter.setTransmission(sara.resources.getResource('FF01-607_70.txt'));
                otherwise
                    warning('Filter not set. Unrecognized name: %s', filterName);
            end
            channel.addDevice(filter);
        end
    end
end