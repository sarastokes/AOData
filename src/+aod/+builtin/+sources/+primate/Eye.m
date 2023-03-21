classdef Eye < aod.core.sources.Eye 
% EYE
%
% Description:
%   Primate eye
%
% Parent:
%   aod.core.sources.Eye
%
% Constructor:
%   obj = Eye(whichEye, varargin)
%
% Parameters:
%   AxialLength                 double
%       Axial length in mm
%   PupilSize                   double
%       Pupil size in mm (default = 6.7 mm)
%   ContactLens                 string
%       Contact lens used for the eye
%
% Dependent properties:
%   micronsPerDegree
%
% Methods:
%   value = deg2um(obj, deg)
%   value = um2deg(obj, um)
%   value = micronsPerPixel(obj, fovDegrees)
%   value = degreesPerPixel(obj, fovDegrees)
%   otf = getOTF(obj, wavelength, sf)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (Dependent)
        micronsPerDegree
    end

    methods
        function obj = Eye(whichEye, varargin)
            obj = obj@aod.core.sources.Eye(whichEye, varargin{:});

            obj.setParam('MicronsPerDegree', obj.micronsPerDegree());
        end
        
        
    end

    
    methods
        function value = deg2um(obj, deg)
            value = obj.micronsPerDegree * deg;
        end

        function value = um2deg(obj, um)
            value = um ./ obj.micronsPerDegree;
        end

        function value = get.micronsPerDegree(obj)

            if ~obj.hasParam('AxialLength')
                value = [];
            else
                value = 291.2 * (obj.getParam('AxialLength') / 24.2);
            end
        end

        function value = micronsPerPixel(obj, fovDegrees)
            % MICRONSPERPIXEL
            %
            % Syntax:
            %   umPerPixel = obj.micronsPerPixel(fovDegrees)
            % 
            % Input:
            %   fovDegrees      numeric [1 x 2]
            %       Field of view in degrees
            %
            % Notes:
            %   Assumes 256 lines 
            % -------------------------------------------------------------
            value = obj.deg2um(fovDegrees) / 256;
        end

        function value = degreesPerPixel(obj, fovDegrees)
            % DEGREESPERPIXEL
            %
            % Syntax:
            %   value = obj.degreesPerPixel(fovDegrees)
            % 
            % Input:
            %   fovDegrees      numeric [1 x 2]
            %       Field of view in degrees
            % -------------------------------------------------------------
            umPerPix = obj.micronsPerPixel(fovDegrees);
            value = obj.um2deg(umPerPix);
        end

        function otf = getOTF(obj, wavelength, sf)
            % GETOTF
            %
            % Syntax:
            %   otf = getOTF(obj, wavelength, sf)
            % -------------------------------------------------------------
            if ~obj.hasParam('PupilSize')
                error('OTF calculation requires pupilSize property!');
            end

            u0 = (obj.getParam('PupilSize') * pi * 10e5) / (wavelength * 180);
            otf = 2/pi * (acos(sf ./ u0) - (sf ./ u0) .* sqrt(1 - (sf./u0).^2));
        end
    end

    methods (Access = protected)
        function value = getExpectedParameters(obj)
            value = getExpectedParameters@aod.core.sources.Eye(obj);

            value.add('ContactLens', [], @isstring,...
                'Contact lens used for the eye');
            value.add('AxialLength', [], @isnumeric,...
                'Axial length of the eye in mm');
            value.add('PupilSize', 6.7, @isnumeric,...
                'Pupil size of the eye in mm');
            value.add('MicronsPerDegree', [], @isnumeric,...
                'Microns per degree of visual angle, from axial length');
        end
    end
end