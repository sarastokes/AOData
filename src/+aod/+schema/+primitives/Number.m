classdef Number < aod.schema.primitives.Primitive
% NUMBER
%
% Superclasses:
%   aod.schema.primitives.Primitive
%
% Description:
%   A number is a scalar, vector or matrix of numeric values. The values
%   may have decimal points, unlike the "integer" class. The format is
%   fixed as "double".
%
% Constructor:
%   obj = aod.specification.Number(name, varargin)
%   obj = aod.specification.Number(name,...
%       'Size', size, 'Description', description, 'Units', units,
%       'Minimum', minimum, 'Maximum', maximum, 'Default', default)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Minimum             aod.schema.specs.Minimum
        Maximum             aod.schema.specs.Maximum
        Units               aod.schema.specs.Units
    end

    properties (Hidden, SetAccess = protected)
        PRIMITIVE_TYPE = aod.schema.primitives.PrimitiveTypes.NUMBER
        OPTIONS =  ["Default", "Description", "Size", "Minimum", "Maximum", "Units"];
        VALIDATORS = ["Format", "Size", "Minimum", "Maximum"];
    end

    methods
        function obj = Number(name, varargin)
            obj = obj@aod.schema.primitives.Primitive(name);

            % Initialize
            obj.Minimum = aod.schema.specs.Minimum(obj, []);
            obj.Maximum = aod.schema.specs.Maximum(obj, []);
            obj.Units = aod.schema.specs.Units(obj, []);

            % Fixed values for numeric
            %% TODO: Add support for single?
            obj.Format.setValue('double');

            obj.setName(name);
            obj.parseInputs(varargin{:});
        end
    end

    methods
        function setUnits(obj, units)
            arguments
                obj
                units       string          {mustBeScalarOrEmpty}
            end

            obj.Units.setValue(units);
        end

        function setMinimum(obj, value)
            %SETMINIMUM
            %
            % Description:
            %   Set the minimum allowed value of the number.
            %
            % Syntax:
            %   setMinimum(obj, value)
            %
            % See also:
            %   setMaximum
            % -----------------------------------------------------------------

            arguments
                obj
                value       {mustBeScalarOrEmpty}
            end

            obj.Minimum.setValue(value);
        end

        function setMaximum(obj, value)
            arguments
                obj
                value       {mustBeScalarOrEmpty}
            end

            obj.Maximum.setValue(value);
        end
    end

    methods (Access = protected)
        function checkIntegrity(obj)
            if ~isempty(obj.Minimum) && ~isempty(obj.Maximum)
                if obj.Minimum > obj.Maximum
                    error('checkIntegrity:InvalidRange',...
                        'Minimum (%.2f) must be less than or equal to maximum (%.2f).',...
                        obj.Minimum.Value, obj.Maximum.Value);
                end
            end
        end
    end
end
