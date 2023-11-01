classdef Eye < aod.core.sources.Eye
% Primate eye
%
% Parent:
%   aod.core.sources.Eye
%
% Constructor:
%   obj = aod.builtin.sources.Eye(whichEye, varargin)
%
% Attributes:
%   AxialLength                 double
%       Axial length in mm
%   PupilDiameter                   double
%       Pupil size in mm (default = 6.7 mm)
%   ContactLens                 string
%       Contact lens used for the eye
%
% Dependent properties:
%   micronsPerDegree                double
%       Microns per degree of visual angle
%
% Methods:
%   value = deg2um(obj, deg)
%   value = um2deg(obj, um)
%   otf = getOTF(obj, wavelength, sf)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (Dependent)
        micronsPerDegree            double
    end

    methods
        function obj = Eye(whichEye, varargin)
            obj = obj@aod.core.sources.Eye(whichEye, varargin{:});
        end

        function value = get.micronsPerDegree(obj)
            if obj.hasAttr('AxialLength')
                value = 291.2 * (obj.getAttr('AxialLength') / 24.2);
            else
                value = [];
            end
        end
    end

    methods
        function value = deg2um(obj, deg)
            % Convert degrees to microns
            %
            % Syntax:
            %   value = deg2um(obj, um)
            % -------------------------------------------------------------
            obj.checkAxialLength();
            value = obj.micronsPerDegree * deg;
        end

        function value = um2deg(obj, um)
            % Convert microns to degrees
            %
            % Syntax:
            %   value = um2deg(obj, um)
            % -------------------------------------------------------------

            obj.checkAxialLength();
            value = um ./ obj.micronsPerDegree;
        end

        function otf = getOTF(obj, wavelength, sf)
            % Calculate the OTF
            %
            % Syntax:
            %   otf = getOTF(obj, wavelength, sf)
            % -------------------------------------------------------------
            if ~isempty(obj.getAttr('PupilDiameter'))
                error('getOTF:NoPupilDiameter',...
                    'OTF calculation requires pupilDiameter property!');
            end

            u0 = (obj.getAttr('PupilSize') * pi * 10e5) / (wavelength * 180);
            otf = 2/pi * (acos(sf ./ u0) - (sf ./ u0) .* sqrt(1 - (sf./u0).^2));
        end
    end

    methods (Static)
        function UUID = specifyClassUUID()
			 UUID = "517e1c89-1bf2-402f-9de4-87bd9fbba7ff";
		end

        function value = specifyAttributes()
            value = specifyAttributes@aod.core.sources.Eye();

            value.add("ContactLens", "LIST",...
                "Class", "double", "Items", {...
                    {"NUMBER", "Units", "millimeter", "Description", "diameter of contact lens"},...
                    {"NUMBER", "Units", "millimeter", "Description", "base curve of contact lens"},...
                    {"NUMBER", "Units", "diopters", "Description", "power of contact lens"}},...
                "Description", "Contact lens: diameter, base curve, power");
            value.add("AxialLength", "NUMBER",...
                "Size", "(1,1)", "Units", "millimeter",...
                "Description", "Axial length of the eye");
            value.add("PupilDiameter", "NUMBER",...
                "Default", 6.7,...
                "Size", "(1,1)","Units", "millimeter",...
                "Description", "Diameter of the pupil");
        end

        function value = specifyDatasets(value)
            value = specifyDatasets@aod.core.sources.Eye(value);

            value.set("micronsPerDegree", "NUMBER",...
                "Size", "(1,1)",...
                "Units", "microns per degree of visual angle",...
                "Description", "Microns per degree of visual angle, calculated from AxialLength");
        end
    end

    methods (Access = private)
        function checkAxialLength(obj)
            if isempty(obj.getAttr('AxialLength'))
                error('checkAxialLength:NoValue',...
                    'Axial length must be set for this calculation');
            end
        end
    end
end