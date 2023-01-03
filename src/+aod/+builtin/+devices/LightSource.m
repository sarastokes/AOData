classdef LightSource < aod.core.Device
% A light source
%
% Description:
%   A light source within the system/channel
%
% Parent:
%   aod.core.Device
%
% Constructor:
%   obj = aod.builtin.devices.LightSource(wavelength, varargin)
%
% Properties:
%   wavelength
%   spectra
%
% Inherited parameters:
%   Manufacturer
%   Model
%
% Methods:
%   setWavelength(obj, wavelength)
%   setSpectra(obj, spectra)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------
    
    properties (SetAccess = protected)
        % The peak wavelength of the light source (nm)
        wavelength      double
        % The spectra of the light source
        spectra         double 
    end 

    methods
        function obj = LightSource(wavelength, varargin)
            obj = obj@aod.core.Device([], varargin{:});   
            
            obj.setWavelength(wavelength);
        end
    end
    
    methods 
        function setWavelength(obj, wavelength)
            % Set the wavelength in nm
            %
            % Syntax:
            %   setWavelength(obj, wavelength)
            %
            % Inputs:
            %   wavelength      double
            %       The light source wavelength (nm)
            % -------------------------------------------------------------
            obj.wavelength = wavelength;
        end
        
        function setSpectra(obj, spectra)
            % Set the light source's spectra
            %
            % Syntax:
            %   setSpectra(obj, spectra)
            %
            % Inputs:
            %   spectra         double
            %       Spectra for light source (first column, nm)
            % -------------------------------------------------------------
            obj.spectra = spectra;
        end
    end

    methods (Access = protected)
        function value = getLabel(obj)
            if ~isempty(obj.Name)
                value = [obj.Name, '_', num2str(obj.wavelength), 'nm'];
            else
                value = [obj.wavelength, 'nm_LightSource'];
            end
        end
    end
end