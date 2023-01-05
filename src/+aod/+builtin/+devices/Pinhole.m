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
% Parameters:
%   Diameter            double
%       Pinhole diameter in microns
%   Model
%   Manufacturer
%
% Sealed methods:
%   setDiameter(obj, diameter)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

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
            obj.setParam('Diameter', diameter);
        end
    end

    methods (Access = protected)
        function value = getLabel(obj)
            value = ['Pinhole_', num2str(obj.getParam('Diameter')), 'microns'];
        end

        function value = getExpectedParameters(obj)
            value = getExpectedParameters@aod.core.Device(obj);
            
            value.add('Diameter', [], @isnumeric,...
                'Pinhole diameter in microns');
        end
    end
end