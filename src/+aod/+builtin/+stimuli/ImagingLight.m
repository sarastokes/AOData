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
%
% Properties:
%   Intensity               double
%       Imaging light intensity
%
% Methods:
%   setIntensity(obj, intensity)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetObservable, SetAccess = private)
        % Intensity of the imaging light 
        intensity               double
    end
    
    methods
        function obj = ImagingLight(name, intensity, varargin)
            obj@aod.core.Stimulus(name, [], varargin{:});

            obj.setIntensity(intensity);
        end

        function setIntensity(obj, intensity)
            % Set imaging light intensity and, optionally, units
            %
            % Syntax:
            %   obj.setIntensity(intensity)
            % -------------------------------------------------------------
            obj.setProp('intensity', intensity);
        end
    end

    methods (Static)
        function value = specifyDatasets(value)
            value = specifyDatasets@aod.core.Stimulus(value);

            % Subclasses should change the units if needed
            value.set("intensity",...
                "Class", "double", "Size", "(1,1)", "Units", "Percent",...
                "Description", "Intensity of the imaging light");
        end
    end
end

