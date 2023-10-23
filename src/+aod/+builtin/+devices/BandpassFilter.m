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

    properties (SetObservable, SetAccess = {?aod.core.Entity})
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
            if istext(transmission)
                transmission = dlmread(transmission);
            end
            obj.setProp('transmission', transmission);
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
        function value = specifyDatasets(value)
            value = specifyDatasets@aod.core.Device(value);

            value.set("transmission",...
                "Class", "double", "Size", "(:,2)", "Units", ["nm", "percent"],...
                "Description", "The transmission spectrum of the filter");
        end

        function value = specifyAttributes()
            value = specifyAttributes@aod.core.Device();

            value.add("Wavelength",...
                "Class", "double", "Size", "(1,1)", "Units", "nm",...
                "Description", "The peak wavelength of the filter");
            value.add("Bandwidth",...
                "Class", "double", "Size", "(1,1)", "Units", "nm",...
                "Description", "The bandwidth of the filter");
        end
    end
end