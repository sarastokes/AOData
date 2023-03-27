classdef BandpassFilter < aod.core.Device
% BANDPASSFILTER
%
% Constructor:
%   obj = aod.builtin.devices.BandpassFilter(wavelength, bandwidth, varargin)
%
% Properties:
%   transmission
%
% Parameters:
%   Wavelength
%   Bandwidth
% Inherited parameters:
%   Manufacturer
%   Model
%
% Methods:
%   setWavelength(obj, wavelength)
%   setBandwidth(obj, bandwidth)
%   setTransmission(obj, transmission)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        transmission
    end

    methods 
        function obj = BandpassFilter(wavelength, bandwidth, varargin)
            obj = obj@aod.core.Device([], varargin{:});
            
            obj.setWavelength(wavelength);
            obj.setBandwidth(bandwidth);
        end
    end

    methods 
        function setWavelength(obj, wavelength)
            assert(isnumeric(wavelength), 'Wavelength must be a number');
            obj.setParam('Wavelength', wavelength);
        end
        
        function setBandwidth(obj, bandwidth)
            assert(isnumeric(bandwidth), 'Bandwidth must be a number');
            obj.setParam('Bandwidth', bandwidth);
        end
        
        function setTransmission(obj, transmission)
            obj.transmission = transmission;
        end
    end

    methods (Access = protected)
        function value = getLabel(obj)
            value = sprintf('%ux%unmBandpassFilter',... 
                obj.getParam('Wavelength'),... 
                obj.getParam('Bandwidth'));
        end

        function value = specifyParameters(obj)
            value = specifyParameters@aod.core.Device(obj);

            value.add('Wavelength', [], @isnumeric,...
                'Wavelength in nm');
            value.add('Bandwidth', [], @isnumeric,...
                'Bandwidth in nm');
        end
    end
end 