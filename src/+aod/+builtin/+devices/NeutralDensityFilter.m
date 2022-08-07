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
% Methods:
%   setAttenuation(obj, attenuation)
% -------------------------------------------------------------------------
    
    properties (SetAccess = protected)
        attenuation 
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
            obj.attenuation = attenuation;
        end
        
        function setTransmission(obj, spectra)
            obj.transmission = spectra;
        end
    end

    methods (Access = protected)
        function value = getLabel(obj)
            value = sprintf('%undf', 10*obj.attenuation);
        end
    end
end