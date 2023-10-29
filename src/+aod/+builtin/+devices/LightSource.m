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
%   spectra
%
% Attributes:
%   Wavelength
%
% Inherited attributes:
%   Manufacturer
%   Model
%
% Methods:
%   setWavelength(obj, wavelength)
%   setSpectra(obj, spectra)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetObservable, SetAccess = {?aod.core.Entity})
        % The spectra of the light source (nm, [])
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
            obj.setAttr('Wavelength', wavelength);
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

            if size(spectra, 1) < size(spectra, 2)
                % Make column if it should be one
                spectra = spectra';
            end
            obj.setProp('spectra', spectra);
        end
    end

    methods (Access = protected)
        function value = specifyLabel(obj)
            value = sprintf("%unmLight", obj.getAttr('Wavelength'));
        end
    end

    methods (Static)
        function value = specifyAttributes()
            value = specifyAttributes@aod.core.Device();

            value.add("Wavelength", "NUMBER",...
                "Size", "(1,1)", "Units", "nm",...
                "Description", "The peak wavelength of the light source");
            value.add("SerialNumber", "TEXT",...
                "Size", "(1,1)",...
                "Description", "The light source's serial number");
        end

        function value = specifyDatasets(value)
            value = specifyDatasets@aod.core.Device(value);

            value.set("spectra", "NUMBER",...
                "Size", "(:, 2)",...
                "Units", ["nm", "microwatt"],...
                "Description", "Spectra of the light source");
        end
    end
end