classdef TopticaImaging < aod.core.Channel
% TOPTICAIMAGING
%
% Description:
%   A channel for imaging with the Toptica
%
% Parent:
%   aod.core.Channel
%
% Constructor:
%   obj = TopticaImaging(parent, laserLine, varargin)
% -------------------------------------------------------------------------
    methods 
        function obj = TopticaImaging(parent, laserLine, varargin)
            obj = obj@aod.core.Channel(parent);
            obj.laserLine = laserLine;

            ip = inputParser();
            ip.KeepUnmatched = true;
            ip.CaseSensitive = false;
            addParameter(ip, 'Pinhole', 20, @isnumeric);
            addParameter(ip, 'Gain', [], @isnumeric);
            parse(ip, varargin{:});

            obj.initialize(ip.Results.Pinhole, ip.Results.Gain);
        end
    end

    methods (Access = private)
        function initialize(obj, pinhole, gain)
            obj.addDevice(aod.core.LightSource(channel, 561,...
                'Manufacturer', 'Toptica'));
            if ~isempty(pinhole)
                obj.addDevice(aod.core.Pinhole(channel, pinhole,...
                    'Manufacturer', 'ThorLabs', 'Model', sprintf('P%uK', pinhole)));
            end
        end
    end
end 