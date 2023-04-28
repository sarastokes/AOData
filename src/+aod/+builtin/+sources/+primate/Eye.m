classdef Eye < aod.core.sources.Eye 
% Primate eye
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
%       Microns per degree of visual angle
%
% Methods:
%   value = deg2um(obj, deg)
%   value = um2deg(obj, um)
%   otf = getOTF(obj, wavelength, sf)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (Dependent)
        micronsPerDegree
    end

    methods
        function obj = Eye(whichEye, varargin)
            obj = obj@aod.core.sources.Eye(whichEye, varargin{:});

            if obj.hasParam('AxialLength')
                obj.setParam('MicronsPerDegree', obj.micronsPerDegree());
            end
        end

        function value = get.micronsPerDegree(obj)
            if isempty(obj.getParam('AxialLength'))
                value = [];
            else
                value = 291.2 * (obj.getParam('AxialLength') / 24.2);
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
            if ~isempty(obj.getParam('PupilSize'))
                error('getOTF:NoPupilSize',...
                    'OTF calculation requires pupilSize property!');
            end

            u0 = (obj.getParam('PupilSize') * pi * 10e5) / (wavelength * 180);
            otf = 2/pi * (acos(sf ./ u0) - (sf ./ u0) .* sqrt(1 - (sf./u0).^2));
        end
    end

    methods (Access = protected)
        function value = specifyParameters(obj)
            value = specifyParameters@aod.core.sources.Eye(obj);

            value.add('ContactLens', [], @isstring,...
                'Contact lens used for the eye');
            value.add('AxialLength', [], @isnumeric,...
                'Axial length of the eye in mm');
            value.add('PupilSize', 6.7, @isnumeric,...
                'Pupil size of the eye in mm');
            value.add('MicronsPerDegree', [], @isnumeric,...
                'Microns per degree of visual angle calculated from axial length');
        end
    end

    methods (Access = private)
        function checkAxialLength(obj)
            if isempty(obj.getParam('AxialLength'))
                error('checkAxialLength:NoValue',...
                    'Axial length must be set for this calculation');
            end
        end
    end
end