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
        Minimum             aod.schema.validators.Minimum
        Maximum             aod.schema.validators.Maximum
        Units               aod.schema.decorators.Units
    end

    properties (Hidden, SetAccess = protected)
        PRIMITIVE_TYPE = aod.schema.primitives.PrimitiveTypes.NUMBER
        OPTIONS =  ["Default", "Description", "Size", "Minimum", "Maximum", "Units"];
        VALIDATORS = ["Format", "Size", "Minimum", "Maximum"];
    end

    methods
        function obj = Number(name, parent, varargin)
            obj = obj@aod.schema.primitives.Primitive(name, parent);

            % Initialize
            obj.Minimum = aod.schema.validators.Minimum(obj, []);
            obj.Maximum = aod.schema.validators.Maximum(obj, []);
            obj.Units = aod.schema.decorators.Units(obj, []);

            % Fixed values for numeric
            %% TODO: Add support for single?
            obj.Format.setValue('double');

            % Complete setup and ensure schema consistency
            obj.parseInputs(varargin{:});
            obj.isInitializing = false;
            obj.checkIntegrity(true);
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
            %SETMINIMUM Set the minimum allowed value of the number.
            %
            % Syntax:
            %   setMinimum(obj, value)
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

    methods
        function [tf, ME] = checkIntegrity(obj, throwErrors)
            arguments
                obj
                throwErrors         logical     = false
            end

            if obj.isInitializing
                tf = true; ME = [];
                return
            end

            [~, ~, excObj] = checkIntegrity@aod.schema.primitives.Primitive(obj);
            if ~isempty(obj.Minimum) && ~isempty(obj.Maximum)
                if obj.Minimum > obj.Maximum
                    excObj.addCause(MException('checkIntegrity:InvalidRange',...
                        'Minimum (%.2f) must be less than or equal to maximum (%.2f).',...
                        obj.Minimum.Value, obj.Maximum.Value));
                end
            end
            tf = excObj.hasErrors();
            ME = excObj.getException();
            if ~tf && throwErrors
                throw(ME);
            end
        end
    end
end
