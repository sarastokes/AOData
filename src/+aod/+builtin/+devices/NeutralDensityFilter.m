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
    
    properties (SetAccess = protected)
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
            assert(isnumeric(attenuation), 'Attenuation must be a number');
            obj.setAttr('Attenuation', attenuation);
        end
        
        function setTransmission(obj, spectra)
            obj.transmission = spectra;
        end
    end

    methods (Access = protected)
        function value = specifyLabel(obj)
            value = sprintf("%.2gNDF", obj.getAttr('Attenuation'));
        end
    end 

    methods (Static)
        function value = specifyDatasets(value)
            value = specifyDatasets@aod.core.Device(value);

            value.set("transmission",...
                "Class", "double", "Size", "(:,1)", "Units", ["nm", "%"],...
                "Description", "The transmission spectrum of the NDF");
        end

        function value = specifyAttributes()
            value = specifyAttributes@aod.core.Device();

            value.add("Attenuation",...
                "Class", "double", "Size", "(1,1)",...
                "Description", "Attenuation of the NDF.");
        end
    end
end