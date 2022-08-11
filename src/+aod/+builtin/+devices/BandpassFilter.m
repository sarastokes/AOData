classdef BandpassFilter < aod.core.Device
% BANDPASSFILTER
%
% Constructor:
%   obj = BandpassFilter(parent, wavelength, bandwidth, varargin)
%
% Properties:
%   wavelength
%   bandwidth
%   transmission
% Inherited properties:
%   manufacturer
%   model
%
% Methods:
%   setWavelength(obj, wavelength)
%   setBandwidth(obj, bandwidth)
%   setTransmission(obj, transmission)
% -------------------------------------------------------------------------
    properties (SetAccess = private)
        wavelength
        bandwidth
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
            obj.wavelength = wavelength;
        end
        
        function setBandwidth(obj, bandwidth)
            obj.bandwidth = bandwidth;
        end
        
        function setTransmission(obj, transmission)
            obj.transmission = transmission;
        end
    end

    methods (Access = protected)
        function value = getLabel(obj)
            value = sprintf('%u_%u', obj.wavelength, obj.bandwidth);
        end
    end
end 