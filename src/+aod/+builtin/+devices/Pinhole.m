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
% Attributes:
%   Diameter            double
%       Pinhole diameter in microns
%   Model               string
%       Model name/number
%   Manufacturer        string
%       Manufacturer
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
            obj.setAttr('Diameter', diameter);
        end
    end

    methods (Access = protected)
        function value = specifyLabel(obj)
            value = sprintf("Pinhole_%umicrons", num2str(obj.getAttr('Diameter')));
        end
    end

    methods (Static)
        function value = specifyAttributes()
            value = specifyAttributes@aod.core.Device();
            
            value.add('Diameter', [], @isnumeric,...
                'Pinhole diameter in microns');
        end
    end
end