classdef MustangImaging < aod.core.Channel
% MUSTANGIMAGING
%
% Description:
%   Sets Mustang imaging channel
%
% Parent:
%   aod.core.Channel
%
% Constructor:
%   obj = MustangImaging(parent, varargin)
% -------------------------------------------------------------------------

    methods 
        function obj = MustangImaging(parent, varargin)
            obj = aod.core.Channel(parent);
            obj.setDataFolder('Vis');

            ip = inputParser();
            ip = KeepUnmatched = true;
            ip.CaseSensitive = false;
            addParameter(ip, 'Pinhole', 20, @isnumeric);
            addParameter(ip, 'Gain', [], @isnumeric);
            parse(ip, varargin{:});

            obj.initialize(ip.Results.Pinhole, ip.Results.Gain);          
        end
    end

    methods (Access = private)
        function initialize(obj, pinhole, gain)
            obj.addDevice(aod.builtin.devices.Pinhole([], pinhole,...
                'Manufacturer', 'ThorLabs', 'Model', sprintf('P%uK', pinhole));
            obj.addDevice(aod.builtin.devices.PMT([], 'Gain', gain,...
                'Manufacturer', 'Hamamatsu', 'Model', 'H16722'));
            obj.addDevice(aod.builtin.devices.LightSource([], 488,...
                'Manufacturer', 'Qioptiq'));
            obj.addDevice(aod.builtin.devices.BandpassFilter([], 520, 35));
        end
    end
end 