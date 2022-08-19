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
%   obj = Eye(parent, whichEye, varargin)
%
% Parameters:
%   AxialLength                 double, axial length in mm
%   PupilSize                   double, pupil size in mm
%   ContactLens
%
% Dependent properties:
%   subjectName                 name of parent aod.core.sources.Subject
%   micronsPerDegree
%
% Methods:
%   value = deg2um(obj, deg)
%   value = um2deg(obj, um)
%   value = micronsPerPixel(obj, fovDegrees)
%   value = degreesPerPixel(obj, fovDegrees)
%   otf = getOTF(obj, wavelength, sf)
% -------------------------------------------------------------------------

    properties (Dependent)
        subjectName
        micronsPerDegree
    end

    methods
        function obj = Eye(parent, whichEye, varargin)
            obj = obj@aod.core.sources.Eye(parent, whichEye);

            ip = inputParser();
            ip.KeepUnmatched = true;
            ip.CaseSensitive = false;
            addParameter(ip, 'ContactLens', [], @ischar);
            addParameter(ip, 'AxialLength', [], @isnumeric);
            addParameter(ip, 'PupilSize', [], @isnumeric);
            parse(ip, varargin{:});

            obj.setParam(ip.Results);
        end

        function value = get.subjectName(obj)
            h = obj.ancestor('aod.core.sources.Subject');
            if ~isempty(h)
                value = h.Name;
            else
                value = [];
            end
        end
        
        function value = get.micronsPerDegree(obj)
            if isempty(obj.sourceParameters('AxialLength'))
                value = [];
            else
                value = 291.2 * (obj.sourceParameters('AxialLength') / 24.2);
            end
        end
    end

    
    methods
        function value = deg2um(obj, deg)
            value = obj.micronsPerDegree * deg;
        end

        function value = um2deg(obj, um)
            value = um ./ obj.micronsPerDegree;
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
            if isempty(obj.sourceParameters('PupilSize'))
                error('OTF calculation requires pupilSize property!');
            end

            u0 = (obj.sourceParameters('PupilSize') * pi * 10e5) / (wavelength * 180);
            otf = 2/pi * (acos(sf ./ u0) - (sf ./ u0) .* sqrt(1 - (sf./u0).^2));
        end
    end
end