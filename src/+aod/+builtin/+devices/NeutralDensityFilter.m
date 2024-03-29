classdef NeutralDensityFilter < aod.core.Device
% NEUTRALDENSITYFILTER
%
% Description:
%   A neutral density filter within a light path
%
% Parent:
%   aod.core.Device
%
% Constructor:
%   obj = NeutralDensityFilter(attenuation, varargin)
%
% Attributes:
%   Attenuation
% Inherited attributes:
%   Manufacturer
%   Model
%
% Properties:
%   transmission
%
% Methods:
%   setAttenuation(obj, attenuation)
%   setTransmission(obj, spectra)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetObservable, SetAccess = {?aod.core.Entity})
        transmission
    end

    methods
        function obj = NeutralDensityFilter(attenuation, varargin)
            obj = obj@aod.core.Device([], varargin{:});

            obj.setAttenuation(attenuation);
        end
    end

    methods
        function setAttenuation(obj, attenuation)
            % Set the NDF attenuation value
            %
            % Syntax:
            %   setAttenuation(obj, attenuation)
            % -------------------------------------------------------------
            obj.setAttr('Attenuation', attenuation);
        end

        function setTransmission(obj, spectra)
            % Set NDF transmission spectra
            %
            % Syntax:
            %   setTransmission(obj, spectra)
            % -------------------------------------------------------------
            obj.setProp('transmission', spectra);
        end
    end

    methods (Access = protected)
        function value = specifyLabel(obj)
            value = sprintf("%.2gNDF", obj.getAttr('Attenuation'));
        end
    end

    methods (Static)
        function UUID = specifyClassUUID()
			 UUID = "23273323-ba40-40c0-bec6-eea76e502f9d";
		end

        function value = specifyDatasets(value)
            value = specifyDatasets@aod.core.Device(value);

            value.set("transmission", "NUMBER",...
                "Size", "(:,2)", "Units", ["nm", "%"],...
                "Description", "The transmission spectrum of the NDF");
        end

        function value = specifyAttributes()
            value = specifyAttributes@aod.core.Device();

            value.add("Attenuation", "NUMBER",...
                "Size", "(1,1)",...
                "Description", "Attenuation of the NDF.");
        end
    end
end