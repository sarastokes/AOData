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
% Properties:
%   edgeWavelength
%   spectrum
% Inherited properties:
%   manufacturer
%   model
%
% Methods:
%   setEdgeWavelength(obj, wavelength)
%   setSpectrum(obj, spectrum)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        edgeWavelength
        spectrum
    end
    
    methods
        function obj = DichroicFilter(parent, edgeWavelength, varargin)
            obj = obj@aod.core.Device(parent, varargin{:});
            
            obj.setEdgeWavelength(edgeWavelength);
        end
    end
    
    methods
        function setEdgeWavelength(obj, wavelength)
            % SETEDGEWAVELENGTH
            %
            % Syntax:
            %   setEdgeWavelength(obj, wavelength)
            % -------------------------------------------------------------
            obj.edgeWavelength = wavelength;
        end
        
        function setSpectrum(obj, spectrum)
            % SETSPECTRUM
            %
            % Syntax:
            %   setSpectrum(obj, spectrum)
            % -------------------------------------------------------------
            obj.spectrum = spectrum;
        end
    end
end