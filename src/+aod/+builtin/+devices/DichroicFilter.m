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
%   obj = DichroicFilter(parent, edgeWavelength, varargin)
%   
% Parameters:
%   EdgeWavelength
%   PassType                        char, 'low' or 'high'
% Inherited properties:
%   Manufacturer
%   Model
%
% Properties:
%   transmission
%
% Methods:
%   setEdgeWavelength(obj, wavelength)
%   setTransmission(obj, spectrum)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        transmission
    end
    
    methods
        function obj = DichroicFilter(parent, edgeWavelength, passType, varargin)
            obj = obj@aod.core.Device(parent, varargin{:});
            
            obj.setEdgeWavelength(edgeWavelength);
            obj.setPassType(passType);
        end
    end
    
    methods
        function setEdgeWavelength(obj, wavelength)
            % SETEDGEWAVELENGTH
            %
            % Syntax:
            %   setEdgeWavelength(obj, wavelength)
            % -------------------------------------------------------------
            obj.deviceParameters('EdgeWavelength') = wavelength;
        end
        
        function setPassType(obj, passType)
            % SETPASSTYPE
            %
            % Syntax:
            %   setPassType(obj, passType)
            % -------------------------------------------------------------
            assert(ismember(passType, {'low', 'high'}),...
                'PassType must be either ''low'' or ''high''');
            obj.deviceParameters('Pass') = passType;
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
            value = [num2str(obj.deviceParameters('EdgeWavelength')), 'nm',...
                capitalize(obj.deviceParameters('Pass')), 'Pass',...
                'DichroicFilter'];
        end
    end
end