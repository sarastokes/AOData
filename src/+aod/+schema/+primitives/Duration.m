classdef Duration < aod.schema.primitives.Primitive
% Specifies a duration value in seconds, minutes, hours, days, or years.
%
% Constructor:
%   obj = aod.schema.primitives.Duration(name, parent, varargin)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Units           aod.schema.decorators.Units
    end

    properties (Hidden, SetAccess = protected)
        PRIMITIVE_TYPE = aod.schema.primitives.PrimitiveTypes.DURATION
        OPTIONS = ["Size", "Units", "Description"];
        VALIDATORS = ["Class", "Size"];
    end

    methods
        function obj = Duration(name, parent, varargin)
            obj = obj@aod.schema.primitives.Primitive(name, parent);

            obj.Units = aod.schema.decorators.Units(obj, []);

            % Set default values
            obj.setClass("duration");
            obj.setUnits("seconds");

            % Complete setup and ensure schema consistency
            obj.parseInputs(varargin{:});
            obj.isInitializing = false;
            obj.checkIntegrity(true);
        end

        function setUnits(obj, value)
            if isempty(value)
                warning('setUnits:EmptyInput',...
                    'Input is empty. Using default value of "seconds".');
                obj.setUnits("seconds");
                return
            end

            value = obj.getUnitsFormat(value);
            obj.setUnits(value);
        end

        function setDefault(obj, value)
            arguments
                obj
                value       duration
            end

            % Convert if does not match format
            if isduration(value) && ~strcmp(obj.getUnitsFormat(value), obj.Format)
                fcn = obj.getFormatFcn(obj.Format);
            end
        end
    end

    methods
        function [tf, ME] = checkIntegrity(obj, throwErrors)
            arguments
                obj         (1,1)   aod.schema.primitives.Duration
                throwErrors (1,1)   logical = false
            end

            if obj.isInitializing
                tf = true; ME = [];
                return
            end

            [tf, ME, excObj] = checkIntegrity@aod.schema.primitives.Primitive(obj);

            % TODO: Check if units are undefined

            tf = ~excObj.hasErrors();
            ME = excObj.getException();
            if excObj.hasErrors() && throwErrors
                throw(ME);
            end
        end
    end

    methods (Static)
        function out = getUnitsFormat(input)
            if isduration(input)
                input = input.Format;
            end

            switch lower(input)
                case {'s', 'sec', 'second', 'seconds'}
                    out = "seconds";
                case {'m', 'min', 'minute', 'minutes'}
                    out = "minutes";
                case {'h', 'hr', 'hour', 'hours'}
                    out = "hours";
                case {'d', 'day', 'days'}
                    out = "days";
                case {'y', 'yr', 'year', 'years'}
                    out = "years";
                case {'ms', 'msec', 'millisecond', 'milliseconds'}
                    out = "milliseconds";
                otherwise
                    error('getFormat:InvalidInput',...
                        'Invalid input "%s". Valid inputs are: seconds, minutes, hours, days, years or milliseconds', input);
            end
        end

        function out = getFormatFcn(input)
            out = aod.schema.primitives.Duration.getUnitsFormat(input);
            eval(sprintf('out = @(x) %s(x);', input));
        end
    end
end