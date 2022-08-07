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
% Properties:
%   diameter
%   diameterUnits           (default = 'micron')
%
% Sealed methods:
%   setDiameter(obj, diameter, diameterUnits)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        diameter
        diameterUnits                       = 'micron'
    end
    
    methods
        function obj = Pinhole(parent, diameter, varargin)
            obj = obj@aod.core.Device(parent, varargin{:});
            
            ip = inputParser();
            ip.KeepUnmatched = true;
            ip.CaseSensitive = false;
            addParameter(ip, 'DiameterUnits', 'micron', @istext);
            parse(ip, varargin{:});
            
            obj.setDiameter(diameter, ip.Results.DiameterUnits);
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
            obj.diameter = diameter;
            if nargin > 2
                obj.diameterUnits = diameterUnits;
            end
        end
    end
end