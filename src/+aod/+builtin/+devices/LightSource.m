classdef LightSource < aod.core.Device
% LIGHTSOURCE
%
% Description:
%   A light source within the system
%
% Parent:
%   aod.core.Device
%
% Constructor:
%   obj = LightSource(parent, wavelength, varargin)
%
% Parameters:
%   Wavelength
% Inherited properties:
%   Manufacturer
%   Model
%
% Methods:
%   setWavelength(obj, wavelength)
%   setSpectra(obj, spectra)
% -------------------------------------------------------------------------
    
    properties (SetAccess = protected)
        spectra
    end

    properties (Hidden, SetAccess = protected)
        calibrationNames
    end

    properties (Dependent)
        Calibrations
    end
    
    methods
        function obj = LightSource(parent, wavelength, varargin)
            obj = obj@aod.core.Device(parent, varargin{:});            
            obj.setWavelength(wavelength);
        end

        function value = get.Calibrations(obj)
            value = [];
            if isempty(obj.calibrationNames)
                return
            end
            parent = obj.ancestor('aod.core.Experiment');
            for i = 1:numel(obj.calibrationNames)
                value = cat(1, value,...
                    parent.getCalibration(obj.calibrationNames(i)));
            end
        end
    end
    
    methods 
        function setWavelength(obj, wavelength)
            obj.deviceParameters('Wavelength') = wavelength;
        end
        
        function setSpectra(obj, spectra)
            obj.spectra = spectra;
        end
    end
end