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
% Attributes:
%   Wavelength                      numeric
%   PassType                        char, 'low' or 'high'
% Inherited Attributes:
%   Manufacturer
%   Model
%
% Properties:
%   transmission
%
% Methods:
%   setWavelength(obj, wavelength)
%   setTransmission(obj, spectrum)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        % Filter transmission (nm, [])
        transmission        double 
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
            obj.setAttr('Wavelength', wavelength);
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
            obj.setAttr('Pass', passType);
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
            value = sprintf('%unm%sPassFilter',... 
                obj.getAttr('Wavelength'),...
                appbox.capitalize(obj.getAttr('Pass')));
        end
    end

    methods (Static)
        function value = specifyAttributes()
            value = specifyAttributes@aod.core.Device();

            value.add('Pass', [], @(x) ismember(lower(x), ["low", "high"]));
            value.add('Wavelength', [], @isnumeric);
        end
    end
end