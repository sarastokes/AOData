classdef Pinhole < aod.core.Device
% A pinhole with a defined diameter
%
% Description:
%   Represents a pinhole placed within a light path
%
% Parent:
%   aod.core.Device
%
% Constructor:
%   obj = aod.builtin.devices.Pinhole(diameter, varargin)
%
% Properties:
%   Diameter            double
%       Pinhole diameter in microns
%
% Inherited Parameters:
%   Model
%   Manufacturer
%
% Sealed methods:
%   setDiameter(obj, diameter)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        % Pinhole diameter in microns
        diameter        double          
    end

    methods
        function obj = Pinhole(diameter, varargin)
            obj = obj@aod.core.Device([], varargin{:});
            
            obj.setDiameter(diameter);
        end
    end
    
    methods
        function setDiameter(obj, diameter)
            % Set pinhole diameter in microns
            %
            % Syntax:
            %   setDiameter(obj, diameter)
            %
            % Example:
            %   obj.setDiameter(25)
            % -------------------------------------------------------------
            obj.diameter = diameter;
        end
    end

    methods (Access = protected)
        function value = getLabel(obj)
            value = ['Pinhole_', num2str(obj.diameter), 'microns'];
        end
    end
end