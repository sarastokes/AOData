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

    properties (SetObservable, SetAccess = {?aod.core.Entity})
        % Intensity of the imaging light
        intensity               double
    end

    methods
        function obj = ImagingLight(name, intensity, varargin)
            obj@aod.core.Stimulus(name, [], varargin{:});

            obj.setIntensity(intensity);
        end

        function setIntensity(obj, intensity)
            % Set imaging light intensity
            %
            % Syntax:
            %   obj.setIntensity(intensity)
            % -------------------------------------------------------------
            obj.setProp('intensity', intensity);
        end
    end

    methods (Static)
        function UUID = specifyClassUUID()
			 UUID = "8ebec018-c5b3-4255-8da7-987137c94628";
		end

        function value = specifyDatasets(value)
            value = specifyDatasets@aod.core.Stimulus(value);

            % Subclasses should change the units if needed
            value.set("intensity", "NUMBER",...
                "Size", "(1,1)", "Units", "Percent",...
                "Description", "Intensity of the imaging light");
        end
    end
end

