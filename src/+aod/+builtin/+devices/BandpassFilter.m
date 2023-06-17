classdef BandpassFilter < aod.core.Device
% Represents a bandpass filter within a system/channel
%
% Constructor:
%   obj = aod.builtin.devices.BandpassFilter(wavelength, bandwidth, varargin)
%
% Properties:
%   transmission
%
% Attributes:
%   Wavelength
%   Bandwidth
% Inherited attributes:
%   Manufacturer
%   Model
%
% Methods:
%   setWavelength(obj, wavelength)
%   setBandwidth(obj, bandwidth)
%   setTransmission(obj, transmission)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        % Filter transmission (nm, [])
        transmission        double
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
            obj.setAttr('Wavelength', wavelength);
        end
        
        function setBandwidth(obj, bandwidth)
            obj.setAttr('Bandwidth', bandwidth);
        end
        
        function setTransmission(obj, transmission)
            % Set filter transmission
            %
            % Syntax:
            %   setTransmission(obj, transmission)
            % -------------------------------------------------------------
            obj.transmission = transmission;
        end
    end

    methods (Access = protected)
        function value = specifyLabel(obj)
            value = sprintf("%ux%unmBandpassFilter",... 
                obj.getAttr('Wavelength'),... 
                obj.getAttr('Bandwidth'));
        end
    end

    methods (Static)
        function value = specifyAttributes()
            value = specifyAttributes@aod.core.Device();

            value.add('Wavelength', [], @isnumeric, 'Wavelength in nm');
            value.add('Bandwidth', [], @isnumeric, 'Bandwidth in nm');
        end
    end
end 