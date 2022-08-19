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
%   obj = NeutralDensityFilter(parent, attenuation, varargin)
%
% Parameters:
%   Attenuation
% Inherited parameters:
%   Manufacturer
%   Model
%
% Properties:
%   transmission
%
% Methods:
%   setAttenuation(obj, attenuation)
%   setTransmission(obj, spectra)
% -------------------------------------------------------------------------
    
    properties (SetAccess = protected)
        transmission
    end
    
    methods
        function obj = NeutralDensityFilter(parent, attenuation, varargin)
            obj = obj@aod.core.Device(parent, varargin{:});
            obj.setAttenuation(attenuation);
        end
    end
    
    methods
        function setAttenuation(obj, attenuation)
            obj.addParameter('Attenuation', attenuation);
        end
        
        function setTransmission(obj, spectra)
            obj.transmission = spectra;
        end
    end

    methods (Access = protected)
        function value = getLabel(obj)
            value = sprintf('%uNeutralDensityFilter',... 
                10*obj.deviceParameters('Attenuation'));
        end
    end
end