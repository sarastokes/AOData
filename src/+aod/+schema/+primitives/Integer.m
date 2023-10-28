classdef Integer < aod.schema.primitives.Primitive
% INTEGER
%
% Superclasses:
%   aod.schema.primitives.Primitive
%
% Constructor:
%   obj = aod.schema.primitives.Integer(name, varargin)
%   obj = aod.schema.primitives.Integer(name,...
%       "Format", format, "Size", size, "Minimum", minimum,...
%       "Maximum", maximum, "Default", default, "Units", units,...
%       "Description", description)
%
% TODO: Revist casting, it's messy

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Enum        aod.schema.validators.Enum
        Minimum     aod.schema.validators.Minimum
        Maximum     aod.schema.validators.Maximum
        Units       aod.schema.decorators.Units
    end

    properties (Hidden, SetAccess = protected)
        PRIMITIVE_TYPE = aod.schema.primitives.PrimitiveTypes.INTEGER
        OPTIONS = ["Class", "Size", "Minimum", "Maximum", "Default", "Units", "Description"]
        VALIDATORS = ["Class", "Size", "Minimum", "Maximum"];
    end

    methods
        function obj = Integer(name, parent, varargin)
            obj = obj@aod.schema.primitives.Primitive(name, parent);

            % Initialization
            obj.Enum = aod.schema.validators.Enum(obj, []);
            obj.Minimum = aod.schema.validators.Minimum(obj, []);
            obj.Maximum = aod.schema.validators.Maximum(obj, []);
            obj.Units = aod.schema.decorators.Units(obj, []);

            % Complete setup and ensure schema consistency
            obj.parseInputs(varargin{:});
            obj.isInitializing = false;
            obj.checkIntegrity(true);
        end
    end

    methods
        function setDefault(obj, value)
            arguments
                obj
                value       {mustBeInteger} = []
            end
            if isempty(value)
                obj.Default.setValue([]);
                return
            end
            if obj.Class.isSpecified() && ~strcmp(obj.Class.Value, class(value))
                value = cast(value, obj.Class.Value);
            end
            obj.Default.setValue(value);
            obj.checkIntegrity(true);
        end

        function setEnum(obj, value)
            arguments
                obj
                value       {mustBeInteger, mustBeVector} = []
            end

            if isempty(value)
                obj.Enum.setValue([]);
                return
            end

            if obj.Class.isSpecified() && ~isa(value, obj.Class.Value)
                value = cast(value, obj.Class.Value);
            end
            obj.Enum.setValue(value);
            obj.checkIntegrity(true);
        end

        function setMinimum(obj, value)
            arguments
                obj
                value       {mustBeInteger, mustBeScalarOrEmpty}
            end

            if obj.Class.isSpecified() && ~strcmp(obj.Class.Value, class(value))
                value = cast(value, obj.Class.Value);
            end

            obj.Minimum.setValue(value);
            obj.checkIntegrity(true);
        end

        function setMaximum(obj, value)
            arguments
                obj
                value       {mustBeInteger, mustBeScalarOrEmpty}
            end

            if obj.Class.isSpecified() && ~strcmp(obj.Class.Value, class(value))
                value = cast(value, obj.Class.Value);
            end

            obj.Maximum.setValue(value);
            obj.checkIntegrity(true);
        end

        function setClass(obj, value)
            % Set the format of the integer

            if isa(value, 'meta.property')
                % Extract from meta.property to validate (redundant...)
                if hasfield(value, 'Validation') && hasfield(value.Validation, 'Class')
                    value = value.Validation.Class.Name;
                else
                    value = [];
                end
            end

            if isempty(value)
                obj.Class.setValue([]);
                obj.checkIntegrity(true);
                return
            end

            % Validate format
            if strcmp(value, 'double') || ~contains(value, 'int')
                error('setClass:InvalidFormat',...
                    'Format must be an integer type, not %s', value);
            end
            obj.Class.setValue(value);

            if ~obj.Class.isSpecified()
                return
            end

            [minValue, maxValue] = obj.getIntegerRange(obj.Class);
            if ~obj.Minimum.isSpecified()
                obj.Minimum.setValue(minValue);
            end
            if ~obj.Maximum.isSpecified()
                obj.Maximum.setValue(maxValue);
            end

            if obj.Enum.isSpecified() && ~isa(obj.Enum, value)
                try
                    obj.Enum.setValue(cast(obj.Enum.Value, value));
                catch ME
                    newME = MException('setClass:EnumCouldNotCase',...
                        'Enum value is %s not %s and could not be cast', ...
                        class(obj.Enum.Value), value);
                    newME.addCause(ME);
                    throw(newME);
                end
            end


            if obj.Default.isSpecified() && ~isa(obj.Default.Value, obj.Class.Value)
                try
                    obj.Default.setValue(cast(obj.Default.Value, obj.Class.Value));
                catch ME
                    newME = MException('setClass:DefaultCouldNotCase',...
                        'Default value is not %s and could not be cast', value);
                    newME.addCause(ME);
                    throw(newME);
                end
            end
        end

        function setUnits(obj, value)
            arguments
                obj
                value      string = ""
            end

            obj.Units.setValue(value);
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

            excObj = aod.schema.exceptions.SchemaIntegrityException(obj);
            % Refactor - this runs too often, but may be useful in one place
            if obj.Class.isSpecified()
                % Minimum and maximum are set by the format if not already
                % set by the user so isSpecified not required.
                [minValue, maxValue] = obj.getIntegerRange(obj.Class);
                if obj.Minimum.Value < minValue
                    excObj.addCause(MException('checkIntegrity:InvalidMinimum',...
                        'Minimum value is smaller than the minimum value of the format'));
                end
                if obj.Minimum.Value > maxValue
                    excObj.addCause(MException('checkIntegrity:InvalidMaximum',...
                        'Maximum value is larger than the maximum value of the format'));
                end
            end
            if obj.Minimum.isSpecified()
                if any(obj.Default.Value < obj.Minimum.Value)
                    excObj.addCause(MException('checkIntegrity:InvalidDefault',...
                        'Default value is smaller than the minimum value'));
                end
                if obj.Maximum.isSpecified()
                    if obj.Maximum.Value < obj.Minimum.Value
                        excObj.addCause(MException('checkIntegrity:InvalidRange',...
                            'Minimum value %d is larger than Maximum value %d', ...
                            obj.Minimum.Value, obj.Maximum.Value));
                    end
                end
            end

            [tf, ME, ~] = checkIntegrity@aod.schema.primitives.Primitive(obj);
            if ~tf
                cellfun(@(x) addCause(excObj, x), ME.cause);
            end
            if obj.Maximum.isSpecified() && all(obj.Default.Value > obj.Maximum.Value)
                excObj.addCause(MException('checkIntegrity:InvalidDefault',...
                    'Default value is larger than the maximum value'));
            end

            tf = ~excObj.hasErrors();
            ME = excObj.getException();
            if excObj.hasErrors() && throwErrors
                throw(ME);
            end
        end
    end

    methods (Static)
        function [minValue, maxValue] = getIntegerRange(intType)
            if isa(intType, 'aod.schema.validators.Class')
                intType = intType.Value;
            end

            minValue = intmin(intType);
            maxValue = intmax(intType);
        end
    end
end