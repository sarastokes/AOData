classdef Number < aod.schema.Primitive
% NUMBER
%
% Superclasses:
%   aod.schema.Primitive
%
% Description:
%   A number is a scalar, vector or matrix of numeric values. The values
%   may have decimal points, unlike the "integer" class. The format is
%   fixed as "double".
%
% Constructor:
%   obj = aod.specification.Number(varargin)
%   obj = aod.specification.Number(...
%       'Size', size, 'Description', description, 'Units', units,
%       'Minimum', minimum, 'Maximum', maximum, 'Default', default)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Enum                aod.schema.validators.Enum
        Minimum             aod.schema.validators.Minimum
        Maximum             aod.schema.validators.Maximum
        Units               aod.schema.decorators.Units
    end

    properties (Hidden, SetAccess = protected)
        PRIMITIVE_TYPE = aod.schema.PrimitiveTypes.NUMBER
        OPTIONS =  ["Default", "Size", "Minimum", "Maximum", "Enum", "Units", "Description"];
        VALIDATORS = ["Class", "Size", "Minimum", "Maximum", "Enum"];
    end

    methods
        function obj = Number(parent, varargin)
            obj = obj@aod.schema.Primitive(parent);

            % Initialize
            obj.Enum = aod.schema.validators.Enum(obj, []);
            obj.Minimum = aod.schema.validators.Minimum(obj, []);
            obj.Maximum = aod.schema.validators.Maximum(obj, []);
            obj.Units = aod.schema.decorators.Units(obj, []);

            % Fixed values for numeric
            % TODO: Add support for single?
            obj.Class.setValue('double');

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
                units       string          = ""
            end

            obj.Units.setValue(units);
        end

        function setEnum(obj, value)
            arguments
                obj
                value        = []
            end
            if ~isempty(value)
                mustBeNumeric(value);
                mustBeVector(value);
            end

            obj.Enum.setValue(value);
            obj.checkIntegrity(true);
        end

        function setMinimum(obj, value)
            %SETMINIMUM  Set the minimum allowed value (inclusive).

            arguments
                obj
                value       {mustBeScalarOrEmpty}
            end

            obj.Minimum.setValue(value);
            obj.checkIntegrity(true);
        end

        function setMaximum(obj, value)
            %SETMINIMUM  Set the minimum allowed value (inclusive).
            arguments
                obj
                value       {mustBeScalarOrEmpty}
            end

            obj.Maximum.setValue(value);
            obj.checkIntegrity(true);
        end
    end

    methods
        function [tf, ME, excObj] = checkIntegrity(obj, throwErrors)
            arguments
                obj
                throwErrors    (1,1)     logical     = false
            end

            if obj.isInitializing
                tf = true; ME = [];
                return
            end

            [~, ~, excObj] = checkIntegrity@aod.schema.Primitive(obj);
            if obj.Minimum.isSpecified() && obj.Maximum.isSpecified()
                if obj.Minimum.Value > obj.Maximum.Value
                    excObj.addCause(MException('checkIntegrity:InvalidRange',...
                        'Minimum (%s) must be less than or equal to maximum (%s).',...
                        num2str(obj.Minimum.Value), num2str(obj.Maximum.Value)));
                end
            end

            if obj.Enum.isSpecified()
                if obj.Minimum.isSpecified()
                    if any(obj.Enum.Value < obj.Minimum.Value)
                        excObj.addCause(MException('checkIntegrity:InvalidEnum',...
                            'Enum contained values less than Minimum (%s).',...
                            num2str(obj.Minimum.Value)));
                    end
                end
                if obj.Maximum.isSpecified()
                    if any(obj.Enum.Value > obj.Maximum.Value)
                        excObj.addCause(MException('checkIntegrity:InvalidEnum',...
                            'Enum contained values less than Maximum (%s)',... 
                            num2str(obj.Maximum.Value)));
                    end
                end
            end

            tf = ~excObj.hasErrors();
            ME = excObj.getException();
            if excObj.hasErrors() && throwErrors
                throw(ME);
            end
        end
    end
end
