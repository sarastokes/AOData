classdef ImagingLight < aod.core.Stimulus
% IMAGINGLIGHT
%
% Description:
%   A light source held at a constant value during an epoch
%
% Parent:
%   aod.core.Stimulus
%
% Constructor:
%   obj = ImagingLight(parent, value, units)
%
% Methods:
%   setValue(obj, value, units)
%   setUnits(obj, units)
% -------------------------------------------------------------------------
    properties (SetAccess = private)
        value                           double
        valueUnits                      char
    end
    
    methods
        function obj = ImagingLight(parent, value, units)
            if nargin == 0
                parent = [];
            end

            obj@aod.core.Stimulus(parent);

            if nargin > 1
                obj.setValue(value);
            end
            if nargin > 2
                obj.setUnits(units)
            end
        end

        function setValue(obj, value, units)
            % SETVALUE
            %
            % Description:
            %   Set imaging light value and, optionally, units
            %
            % Syntax:
            %   obj.setValue(value, units)
            % -------------------------------------------------------------
            obj.value = value;
            if nargin == 3
                obj.setUnits(units);
            end
        end

        function setUnits(obj, units)
            % SETUNITS
            %
            % Description:
            %   Set units for imaging light value
            %
            % Syntax:
            %   obj.setUnits(units)
            % -------------------------------------------------------------
            obj.valueUnits = units;
        end
    end
end

