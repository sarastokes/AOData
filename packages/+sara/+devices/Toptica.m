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
%   obj = Toptica(parent, laserLine, varargin)
% -------------------------------------------------------------------------

    properties (Hidden, Constant)
        LASER_LINES = [488, 515, 561, 630];
    end

    properties (Dependent)
        Calibrations
    end

    methods
        function obj = Toptica(parent, laserLine, varargin)
            obj = obj@aod.core.LightSource(parent, laserLine,...
                'Manufacturer', 'Toptica', 'Model', 'iChrome MLE',...
                varargin{:});
            assert(ismember(laserLine, obj.LASER_LINES), 'Invalid laser line');
        end
        
        function value = get.Calibrations(obj)
            parent = obj.ancestor('aod.core.Experiment');
            value = cat(1,...
                parent.getCalibration('sara.calibrations.TopticaNonlinearity'),...
                parent.getCalibration('sara.calibrations.TopticaPower'));
        end
    end
end