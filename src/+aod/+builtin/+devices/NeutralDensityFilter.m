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
        function obj = NeutralDensityFilter(attenuation, varargin)
            obj = obj@aod.core.Device([], varargin{:});
            obj.setAttenuation(attenuation);
        end
    end
    
    methods
        function setAttenuation(obj, attenuation)
            assert(isnumeric(attenuation), 'Attenuation must be a number');
            obj.setParam('Attenuation', attenuation);
        end
        
        function setTransmission(obj, spectra)
            obj.transmission = spectra;
        end
    end

    methods (Access = protected)
        function value = getLabel(obj)
            value = sprintf('%uNeutralDensityFilter',... 
                10*obj.getParam('Attenuation'));
        end
    end
end