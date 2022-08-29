classdef Pinhole < aod.core.Device
% PINHOLE
%
% Description:
%   Represents a pinhole placed within a light path
%
% Parent:
%   aod.core.Device
%
% Constructor:
%   obj = Pinhole(parent, diameter, varargin)
%
% Parameters:
%   Diameter
%   DiameterUnits           (default = 'micron')
% Inherited Parameters:
%   Model
%   Manufacturer
%
% Sealed methods:
%   setDiameter(obj, diameter, diameterUnits)
%   setDiameterUnits(obj, diameterUnits)
%
% -------------------------------------------------------------------------

    methods
        function obj = Pinhole(diameter, varargin)
            obj = obj@aod.core.Device([], varargin{:});
            
            obj.setDiameter(diameter);
            
            ip = aod.util.InputParser();
            addParameter(ip, 'DiameterUnits', 'micron', @istext);
            parse(ip, varargin{:});
            
            obj.setDiameterUnits(ip.Results.DiameterUnits);
        end
    end
    
    methods
        function setDiameter(obj, diameter, diameterUnits)
            % SETDIAMETER
            %
            % Description:
            %   Set pinhole diameter and optionally, units of diameter
            %
            % Syntax:
            %   setDiameter(obj, diameter, diameterUnits)
            %   setDiameter(obj, diameter)
            %
            % Notes:
            %   Default diameter units is 'microns'
            % -------------------------------------------------------------
            assert(isnumeric(diameter), 'Diameter must be a number');

            obj.setParam('Diameter', diameter);
            if nargin > 2
                obj.setParam('DiameterUnits', diameterUnits);
            end
        end

        function setDiameterUnits(obj, diameterUnits)
            % SETDIAMETERUNITS
            %
            % Description:
            %   Set units of pinhole diameter
            %
            % Syntax:
            %   setDiameterUnits(obj, diameterUnits)
            %
            % Notes:
            %   Default diameter units is 'microns'
            % -------------------------------------------------------------
            if isempty(diameterUnits)
                diameterUnits = 'micron';
            end
            obj.setParam('DiameterUnits', diameterUnits);
        end
    end

    methods (Access = protected)
        function value = getLabel(obj)
            value = ['Pinhole', num2str(obj.getParam('Diameter')),...
                obj.getParam('DiameterUnits')];
        end
    end
end