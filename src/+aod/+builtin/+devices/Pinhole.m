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
% Inherited parameters:
%   Model
%   Manufacturer
%
% Sealed methods:
%   setDiameter(obj, diameter, diameterUnits)
% -------------------------------------------------------------------------

    methods
        function obj = Pinhole(parent, diameter, varargin)
            obj = obj@aod.core.Device(parent, varargin{:});
            
            ip = inputParser();
            ip.KeepUnmatched = true;
            ip.CaseSensitive = false;
            addParameter(ip, 'DiameterUnits', 'micron', @istext);
            parse(ip, varargin{:});
            
            obj.addParameter('Diameter', diameter);
            obj.addParameter(ip.Results);
        end
    end
    
    methods (Sealed)
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
            obj.addParameter('Diameter', diameter);
            if nargin > 2
                obj.addParameter('DiameterUnits', diameterUnits);
            end
        end
    end
end