classdef Toptica < aod.builtin.devices.LightSource 
% TOPTICA
%
% Description:
%   Multiple wavelength laser
%
% Parent:
%   aod.core.LightSource
%
% Constructor:
%   obj = Toptica(laserLine, varargin)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        laserLines
    end

    methods
        function obj = Toptica(laserLine, varargin)
            obj = obj@aod.builtin.devices.LightSource(laserLine,...
                'Manufacturer', "Toptica", 'Model', "iChrome MLE",...
                varargin{:});

            ip = aod.util.InputParser();
            addParameter(ip, 'HunterLab', true, @islogical);
            parse(ip, varargin{:});

            if ip.Results.HunterLab
                obj.laserLines = [480, 561, 640];
                obj.assignUUID("9fcdc239-6154-496d-bb6c-434276b12fd0");
                obj.setDescription('Borrowed from Hunter lab');
            else
                obj.laserLines = [480, 515, 561, 640];
                obj.assignUUID("e07a1753-07e4-420f-bbb5-5d27eb35e573");
            end
            %assert(ismember(laserLine, obj.laserLines), 'Invalid laser line');
            
            obj.calibrationNames = 'sara.calibrations.TopticaPower';
        end
    end
end