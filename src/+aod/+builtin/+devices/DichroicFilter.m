classdef DichroicFilter < aod.core.Device
% DICHROICFILTER
%
% Description:
%   A dichroic filter within the system
%
% Parent:
%   aod.core.Device
%
% Constructor:
%   obj = DichroicFilter(wavelength, passType, varargin)
%   
% Parameters:
%   Wavelength                      numeric
%   PassType                        char, 'low' or 'high'
% Inherited Parameters:
%   Manufacturer
%   Model
%
% Properties:
%   transmission
%
% Methods:
%   setWavelength(obj, wavelength)
%   setTransmission(obj, spectrum)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        transmission
    end
    
    methods
        function obj = DichroicFilter(wavelength, passType, varargin)
            obj = obj@aod.core.Device([], varargin{:});
            
            obj.setWavelength(wavelength);
            obj.setPassType(passType);
        end
    end
    
    methods
        function setWavelength(obj, wavelength)
            % SETWAVELENGTH
            %
            % Syntax:
            %   setWavelength(obj, wavelength)
            % -------------------------------------------------------------
            assert(isnumeric(wavelength),  'Wavelength must be a number')
            obj.setParam('Wavelength', wavelength);
        end
        
        function setPassType(obj, passType)
            % SETPASSTYPE
            %
            % Syntax:
            %   setPassType(obj, passType)
            % -------------------------------------------------------------
            passType = lower(passType);
            assert(ismember(passType, {'low', 'high'}),...
                'PassType must be either ''low'' or ''high''');
            obj.setParam('Pass', passType);
        end

        function setTransmission(obj, spectra)
            % SETSPECTRUM
            %
            % Syntax:
            %   setSpectrum(obj, spectrum)
            % -------------------------------------------------------------
            obj.transmission = spectra;
        end
    end

    methods (Access = protected)
        function value = getLabel(obj)
            value = [num2str(obj.getParam('Wavelength')), 'nm',...
                appbox.capitalize(obj.getParam('Pass')), 'Pass', 'Filter'];
        end

        function value = specifyParameters(obj)
            value = specifyParameters@aod.core.Device(obj);

            value.add('Pass', [], @(x) ismember(lower(x), ["low", "high"]));
            value.add('Wavelength', [], @isnumeric);
        end
    end
end