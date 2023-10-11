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

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Minimum     aod.schema.specs.Minimum
        Maximum     aod.schema.specs.Maximum
        Units       aod.schema.specs.Units
    end

    properties (Hidden, SetAccess = protected)
        PRIMITIVE_TYPE = aod.schema.primitives.PrimitiveTypes.INTEGER
        OPTIONS = ["Format", "Size", "Minimum", "Maximum", "Default", "Units", "Description"]
    end

    methods
        function obj = Integer(name, varargin)
            obj = obj@aod.schema.primitives.Primitive(name, varargin{:});

            % Initialization
            obj.Minimum = aod.schema.specs.Minimum(obj, []);
            obj.Maximum = aod.schema.specs.Maximum(obj, []);
            obj.Units = aod.schema.specs.Units(obj, []);

            obj.parseInputs(varargin{:});
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
            if ~isempty(obj.Format) && ~strcmp(obj.Format.Value, class(value))
                value = cast(value, obj.Format.Value);
            end
            obj.Default.setValue(value);
        end

        function setMinimum(obj, value)
            arguments
                obj
                value       {mustBeInteger, mustBeScalarOrEmpty}
            end

            if ~isempty(obj.Format) && ~strcmp(obj.Format.Value, class(value))
                value = cast(value, obj.Format.Value);
            end
            obj.Maximum.setValue(value);
        end

        function setMaximum(obj, value)
            arguments
                obj
                value       {mustBeInteger, mustBeScalarOrEmpty}
            end

            if ~isempty(obj.Format) && ~strcmp(obj.Format.Value, class(value))
                value = cast(value, obj.Format.Value);
            end
            obj.Maximum.setValue(value);
        end

        function setFormat(obj, value)
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
                obj.Format.setValue([]);
                return
            end

            % Validate format
            if ~strcmp(value, 'double') && ~contains(value, 'int')
                error('setFormat:InvalidFormat',...
                    'Format must be an integer type');
            end
            %% TODO: Remove integer defaults on switch to double
            obj.Format.setValue(value);
            obj.checkIntegrity();
        end

        function setUnits(obj, value)
            arguments
                obj
                value      string = ""
            end

            obj.Units.setValue(value);
        end
    end

    methods (Access = protected)
        function checkIntegrity(obj)

            % Refactor - this runs too often, but may be useful in one place
            if ~isempty(obj.Format)
                % Check if minimum and maximum are valid
                [minValue, maxValue] = obj.getIntegerRange(obj.Format);
                if isempty(obj.Minimum)
                    obj.Minimum.setValue(minValue);
                elseif obj.Minimum.Value < minValue
                    error('checkIntegrity:InvalidMinimum',...
                        'Minimum value is smaller than the minimum value of the format');
                end
                if isempty(obj.Maximum)
                    obj.Maximum.setValue(maxValue);
                elseif obj.Minimum.Value > maxValue
                    error('checkIntegrity:InvalidMaximum',...
                        'Maximum value is larger than the maximum value of the format');
                end
                if ~isempty(obj.Default) && ~isa(obj.Default.Value, obj.Format.Value)
                    obj.Default.setValue(cast(obj.Default.Value, obj.Format.Value));
                end
            end
            if ~isempty(obj.Minimum)
                if all(obj.Default.Value < obj.Minimum.Value)
                    error('checkIntegrity:InvalidDefault',...
                        'Default value is smaller than the minimum value');
                end
                if ~isempty(obj.Maximum)
                    if all(obj.Maximum.Value < obj.Minimum.Value)
                        error('checkIntegrity:InvalidRange',...
                            'Minimum value %d is larger than Maximum value %d', obj.Minimum.Value, obj.Maximum.Value);
                    end
                end
            end

            checkIntegrity@aod.schema.primitives.Primitive(obj);
            if ~isempty(obj.Maximum) && all(obj.Default.Value > obj.Maximum.Value)
                error('checkIntegrity:InvalidDefault',...
                    'Default value is larger than the maximum value');
            end
        end
    end

    methods (Static)
        function [minValue, maxValue] = getIntegerRange(intType)
            if isa(intType, 'aod.specification.MatlabClass')
                intType = intType.Value;
            end

            minValue = intmin(intType);
            maxValue = intmax(intType);
        end
    end
end