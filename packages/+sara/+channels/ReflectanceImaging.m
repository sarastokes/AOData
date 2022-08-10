classdef ReflectanceImaging < aod.core.Channel
%
% Parent:
%   aod.core.Channel
% -------------------------------------------------------------------------
    methods 
        function obj = ReflectanceImaging(parent, varargin)
            obj = obj@aod.core.Channel(parent);
            
            ip = inputParser();
            ip.KeepUnmatched = true;
            ip.CaseSensitive = false;
            addParameter(ip, 'Pinhole', 20, @isnumeric);
            addParameter(ip, 'Gain', [], @isnumeric);
            parse(ip, varargin{:});

            obj.setDataFolder('Ref');
            obj.initialize();
        end
    end

    methods (Access = private)
        function initialize(obj, pinhole, gain);
            obj.addDevice(aod.core.LightSource(obj, 796,...
                'Manufacturer', 'SuperLum'));
            if ~isempty(obj.pinhole)
                obj.addDevice(aod.core.devices.Pinhole(obj, pinhole,...
                    'Manufacturer', 'ThorLabs', 'Model', sprintf('P%uK', pinhole)));
            end
            obj.addDevice(aod.core.devices.PMT(obj, 'Gain', gain));
        end
    end
end 