classdef ChannelFactory < aod.core.Factory

    methods
        function obj = ChannelFactory()
            % Do nothing
        end

        function channel = get(obj, channelName, varargin) 
            ip = inputParser();
            ip.KeepUnmatched = true;
            addParameter(ip, 'NDF', [], @isnumeric);
            addParameter(ip, 'Filter', [], @ischar);
            addParameter(ip, 'TopticaLine', [], @isnumeric);
            addParameter(ip, 'Pinhole', [], @isnumeric);
            parse(ip, varargin{:});

            NDF = ip.Results.NDF;
            filterName = ip.Results.Filter;
            pinhole = ip.Results.Pinhole;
            topticaLine = ip.Results.TopticaLine;

            switch channelName 
                case 'ReflectanceImaging'
                    channel = aod.core.Channel([], 'ReflectanceImaging');
                    channel.addDevice(aod.builtin.devices.LightSource([], 796,...
                        'Manufacturer', 'SuperLum'));
                    if ~isempty(pinhole) && pinhole ~= 20
                        channel = obj.addPinhole(channel, pinhole);
                    else
                        channel.addDevice(aod.builtin.devices.Pinhole([], 20,...
                            'Manufacturer', 'ThorLabs', 'Model', 'P20K'));
                    end
                    channel.setDataFolder('Ref');
                    % TODO: Add PMT
                case 'WavefrontSensing'
                    channel = aod.core.Channel([], 'WavefrontSensing');
                    channel.addDevice(aod.builtin.devices.LightSource([], 847,...
                        'Manufacturer', 'QPhotonics'));
                case 'MustangImaging'
                    channel = aod.core.Channel([], 'MustangImaging');
                    channel.setDataFolder('Vis');
                    channel.addDevice(aod.builtin.devices.PMT([], 'Gain', 0.805,...
                        'Manufacturer', 'Hamamatsu', 'Model', 'H16722'));
                    channel.addDevice(aod.builtin.devices.LightSource([], 488,...
                        'Manufacturer', 'Qioptiq'));
                    channel.addDevice(aod.builtin.devices.BandpassFilter([], 520, 15));
                    channel.addDevice(aod.builtin.devices.PMT([],...
                        'Manufacturer', 'Hamamatsu', 'Model', 'H16722'));
                    if ~isempty(pinhole)
                        channel = obj.addPinhole(channel, pinhole);
                    end
                case 'TopticaImaging'
                    channel = aod.core.Channel([], 'TopticaImaging');
                    channel.setDataFolder('Vis');
                    channel.addDevice(sara.devices.Toptica([], topticaLine));
                    channel.addDevice(aod.builtin.devices.PMT([],...
                        'Manufacturer', 'Hamamatsu', 'Model', 'H16722'));
                    if ~isempty(filterName)
                        channel = obj.addFilter(channel, filterName);
                    else
                        warning('ChannelFactory: Filter for TopticaImaging not specified');
                    end
                    if ~isempty(pinhole)
                        channel = obj.addPinhole(channel, pinhole);
                    end
                case 'TopticaStimulation'
                    channel = aod.core.Channel([], 'TopticaImaging');
                    channel.addDevice(sara.devices.Toptica([], topticaLine));                    
                case 'MaxwellianView'
                    channel = aod.core.Channel([], 'MaxwellianView');
                    % Add the LEDs
                    channel.addDevice(aod.builtin.devices.LightSource([], 660,...
                        'Manufacturer', 'ThorLabs', 'Model', 'M660L4'));
                    channel.addDevice(aod.builtin.devices.LightSource([], 530,...
                        'Manufacturer', 'ThorLabs', 'Model', 'M530L4'));
                    channel.addDevice(aod.builtin.devices.LightSource([], 420,...
                        'Manufacturer', 'ThorLabs', 'Model', 'M420L4'));
                    % Add the dichroic filters
                    ff470 = aod.builtin.devices.DichroicFilter([], 470,...
                        'Manufacturer', 'Semrock', 'Model', 'FF470-Di01');
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

            % Add the NDF, if necessary
            if ~isempty(NDF)
                channel = obj.addNDF(channel, NDF);
            end

            % Add additional inputs to channelParameters
            if ~isempty(ip.Unmatched)
                channel.addParameter(ip.Unmatched);
            end
        end
    end
    
    methods (Static)
        function out = create(channelName, system, varargin)
            obj = sara.factories.ChannelFactory();
            channel = obj.get(channelName, varargin{:});
            if nargin > 1
                assert(isSubclass(system, 'aod.core.System'));
                system.addChannel(channel);
                out = system;
            else
                out = channel;
            end
        end

        function channel = addPinhole(channel, pinhole)
            pinhole = aod.builtin.devices.Pinhole(channel, pinhole,...
                'Manufacturer', 'ThorLabs', 'Model', sprintf('P%uK', pinhole));
            channel.addDevice(pinhole);
        end

        function channel = addNDF(channel, attenuation)
            ndf = aod.builtin.devices.NeutralDensityFilter([], attenuation,...
                'Manufacturer', 'ThorLabs', 'Model', sprintf('NE%uA-A', 10*attenuation));
            ndf.setTransmission(sara.resources.getResource(...
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