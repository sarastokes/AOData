classdef BandpassFilter < aod.core.Device
% BANDPASSFILTER
%
% Constructor:
%   obj = BandpassFilter(parent, wavelength, bandwidth, varargin)
%
% Parameters:
%   wavelength
%   bandwidth
% Inherited parameters:
%   manufacturer
%   model
%
% Properties:
%   transmission
%
% Methods:
%   setWavelength(obj, wavelength)
%   setBandwidth(obj, bandwidth)
%   setTransmission(obj, transmission)
% -------------------------------------------------------------------------
    properties (SetAccess = protected)
        transmission
    end

    methods 
        function obj = BandpassFilter(parent, wavelength, bandwidth, varargin)
            obj = obj@aod.core.Device(parent, varargin{:});
            
            obj.setWavelength(wavelength);
            obj.setBandwidth(bandwidth);
        end
    end

    methods 
        function setWavelength(obj, wavelength)
            obj.addParameter('Wavelength', wavelength);
        end
        
        function setBandwidth(obj, bandwidth)
            obj.addParameter('Bandwidth', bandwidth);
        end
        
        function setTransmission(obj, transmission)
            obj.transmission = transmission;
        end
    end

    methods (Access = protected)
        function value = getLabel(obj)
            value = sprintf('%u_%unmBandpassFilter', obj.deviceParameters('Wavelength'),... 
                obj.deviceParameters('Bandwidth'));
        end
    end
end 