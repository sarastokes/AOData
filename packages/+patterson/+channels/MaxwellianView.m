classdef MaxwellianView < aod.core.Channel
% MAXWELLIANVIEW
%
% Description:
%   A channel representing the standard Maxwellian View setup
%
% Parent:
%   aod.core.Channel
%
% Constructor:
%   obj = MaxwellianView(parent, varargin)
% -------------------------------------------------------------------------

    methods
        function obj = MaxwellianView(parent, varargin)
            obj = aod.core.Channel(parent);
            
            ip = inputParser();
            ip.KeepUnmatched = true;
            ip.CaseSensitive = false;
            addParameter(ip, 'NDF', [], @isnumeric);
            addParameter(ip, 'Using590', false, @islogical);
            parse(ip, varargin{:});
            
            obj.initialize(ip.Results.NDF, ip.Results.Using590);
        end
    end
    
    methods (Access = private)
        function initialize(~, ndf, using590)

            % Add the LEDs
            obj.addDevice(aod.builtin.devices.LightSource([], 660,...
                'Manufacturer', 'ThorLabs', 'Model', 'M660L4'));
            if using590
                channel.addDevice(aod.builtin.devices.LightSource([], 590,...
                    'Manufacturer', 'ThorLabs', 'Model', 'M590L4'));
            else
                obj.addDevice(aod.builtin.devices.LightSource([], 530,...
                    'Manufacturer', 'ThorLabs', 'Model', 'M530L4'));
            end
            obj.addDevice(aod.builtin.devices.LightSource([], 420,...
                'Manufacturer', 'ThorLabs', 'Model', 'M420L4'));
            
            % Add the dichroic filters
            ff470 = aod.builtin.devices.DichroicFilter([], 470,...
                'Manufacturer', 'Semrock', 'Model', 'FF47-Di01');
            ff470.setSpectrum(dlmread(...
                patterson.resources.loadResource('FF470_Di01.txt')));
            obj.addDevice(ff470);
            ff562 = aod.builtin.devices.DichroicFilter([], 562,...
                'Manufacturer', 'Semrock', 'Model', 'FF562_Di03');
            ff562.setSpectrum(dlmread(...
                patterson.resources.loadResource('FF562_Di03.txt')));
            obj.addDevice(ff562);
            ff649 = aod.builtin.devices.DichroicFilter([], 649,...
                'Manufacturer', 'Semrock', 'Model', 'FF649-Di01');
            ff649.setSpectrum(dlmread(...
                patterson.resources.loadResource('FF649_Di01.txt')));
            obj.addDevice(ff649);
            
            % Add the NDF 
            if ~isempty(NDF)
                ndf = aod.builtin.NeutralDensityFilter(obj, ndf,...
                    'Model', sprintf('NE%sA-A', int2fixedwidthstr(ndf, 2)));
                [filePath, tf] = patterson.resources.getResource('NE%sA.txt',...
                    int2fixedwidthstr(ndf, 2));
                if tf
                    ndf.setTransmission(dlmread(filePath));
                end
                obj.addDevice(ndf);
            end
                
        end
    end
end