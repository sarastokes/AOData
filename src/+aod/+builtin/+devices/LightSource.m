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
% Properties:
%   wavelength
%   spectra
% Inherited properties:
%   manufacturer
%   model
%
% Methods:
%   setWavelength(obj, wavelength)
%   setPosition(obj, spectra)
% -------------------------------------------------------------------------
    
    properties (SetAccess = private)
        wavelength
        spectra
    end
    
    methods
        function obj = LightSource(parent, wavelength, varargin)
            obj = obj@aod.core.Device(parent, varargin{:});
            
            obj.setWavelength(wavelength);
        end
    end
    
    methods 
        function setWavelength(obj, wavelength)
            obj.wavelength = wavelength;
        end
        
        function setSpectra(obj, spectra)
            obj.spectra = spectra;
        end
    end
end