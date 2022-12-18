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
%   obj = LightSource(wavelength, varargin)
%
% Parameters:
%   Wavelength
% Inherited properties:
%   Manufacturer
%   Model
%
% Methods:
%   setWavelength(obj, wavelength)
%   setSpectra(obj, spectra)
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
            
            ip = aod.util.InputParser();
            addParameter(ip, 'SerialNumber', [], @isstring);
            parse(ip, varargin{:});
            
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
            obj.setParam('Wavelength', wavelength);
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
                value = [obj.Name, num2str(obj.getParam('Wavelength')), 'nm'];
            else
                value = [num2str(obj.getParam('Wavelength')), 'nmLightSource'];
            end
        end
    end
end