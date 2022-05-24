classdef Eye < aod.core.Source 

    properties (SetAccess = private)
        whichEye
        axialLength
        pupilSize
    end

    properties (Dependent)
        micronsPerDegree
    end

    methods
        function obj = Eye(parent, whichEye, varargin)
            obj@aod.core.Source(parent);
            obj.whichEye = whichEye;

            ip = inputParser();
            ip.CaseSensitive = false;
            addParameter(ip, 'AxialLength', [], @isnumeric);
            addParameter(ip, 'PupilSize', [], @isnumeric);
            parse(ip, varargin{:});
        end
        
        function value = get.micronsPerDegree(obj)
            if ~isempty(obj.axialLength)
                value = 291.2 * (obj.axialLength / 24.2);
            else
                error('Axial length not set!');
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
            if isempty(obj.pupilSize)
                error('OTF calculation requires pupilSize property!');
            end

            u0 = (obj.pupilSize() * pi * 10e5) / (wavelength * 180);
            otf = 2/pi * (acos(sf ./ u0) - (sf ./ u0) .* sqrt(1 - (sf./u0).^2));
        end
    end
end