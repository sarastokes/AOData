classdef ChannelFactory < aod.core.Factory

    methods 
        function obj = ChannelFactory()
            % Do nothing
        end
        
        function channel = get(obj, channelName)
            switch lower(channelName)
                case 'maxwellianview'
                    ledChannel = aod.core.Channel([]);
                    % Add the dichroic filters
                    ff470 = aod.builtin.devices.DichroicFilter([], 470,...
                        'Manufacturer', 'Semrock', 'Model', 'FF47-Di01');
                    ff470.setSpectrum(dlmread(patterson.resources.loadResource('FF470_Di01.txt')));
                    ledChannel.addDevice(ff470);
                    ff562 = aod.builtin.devices.DichroicFilter([], 562,...
                        'Manufacturer', 'Semrock', 'Model', 'FF562_Di03');
                    ff562.setSpectrum(dlmread(patterson.resources.loadResource('FF562_Di03.txt')));
                    ledChannel.addDevice(ff562);
                    ff649 = aod.builtin.devices.DichroicFilter([], 649,...
                        'Manufacturer', 'Semrock', 'Model', 'FF649-Di01');
                    ff649.setSpectrum(dlmread(patterson.resources.loadResource('FF649_Di01.txt')));
                    channel.addDevice(ff649);
                case 'mustangimaging'
                case 'topticastimulation'
                case 'reflectanceimaging'
                otherwise
                    error('Channel %s not found', channelName);
            end
        end
    end
    
    methods
        function channel = addNDF(channel, attenuation)
            ndf = aod.builtin.NeutralDensityFilter(channel, attenuation,...
                'Model', sprintf('NE%sA-A', int2fixedwidthstr(attenuation, 2)));
            [filePath, tf] = patterson.resources.getResource('NE%sA.txt',...
                int2fixedwidthstr(attenuation, 2));
            if tf
                ndf.setTransmission(dlmread(filePath));
            end
            channel.addDevice(ndf);
        end
    end

    methods (Static)
        function channel = create(channelName)
            obj = patterson.factories.ChannelFactory();
            channel = obj.create(channelName);
        end
    end
end