classdef ImagingLight < aod.core.Stimulus
% A constant imaging light
%
% Description:
%   A light source held at a constant value with no protocol
%
% Parent:
%   aod.core.Stimulus
%
% Constructor:
%   obj = ImagingLight(name, intensity)
%   obj = ImagingLight(name, intensity, units)
%
% Properties:
%   Intensity               double
%       Imaging light intensity
%
% Parameters:
%   IntensityUnits          string
%       Units for the specified imaging light intensity
%
% Methods:
%   setIntensity(obj, intensity, units)
%   setUnits(obj, units)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        % Intensity of the imaging light 
        intensity                           double
    end
    
    methods
        function obj = ImagingLight(name, intensity, varargin)
            obj@aod.core.Stimulus(name, [], varargin{:});

            obj.setIntensity(intensity);
        end

        function setIntensity(obj, intensity, units)
            % Set imaging light intensity and, optionally, units
            %
            % Syntax:
            %   obj.setIntensity(intensity)
            %   obj.setIntensity(intensity, units)
            % -------------------------------------------------------------
            obj.intensity = intensity;
            if nargin == 3
                obj.setUnits(units);
            end
        end

        function setUnits(obj, units)
            % Set units for imaging light intensity
            %
            % Syntax:
            %   obj.setUnits(units)
            % -------------------------------------------------------------
            obj.setParam('IntensityUnits', units);
        end
    end

    methods (Access = protected)
        function value = specifyParameters(obj)
            value = specifyParameters@aod.core.Stimulus(obj);

            value.add('IntensityUnits', [], @istext,...
                "Units for the imaging light intensity");
        end
    end
end

