classdef Toptica < aod.core.LightSource 
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

    properties (Dependent)
        Calibrations
    end

    methods
        function obj = Toptica(laserLine, varargin)
            obj = obj@aod.core.LightSource(laserLine,...
                'Manufacturer', 'Toptica', 'Model', 'iChrome MLE',...
                varargin{:});
            assert(ismember(laserLine, obj.LASER_LINES), 'Invalid laser line');
            ip = inputParser();
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
        end
        
        function value = get.Calibrations(obj)
            parent = obj.ancestor('aod.core.Experiment');
            value = cat(1,...
                parent.getCalibration('sara.calibrations.TopticaPower'));
        end
    end
end