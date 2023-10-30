classdef Duration < aod.schema.Primitive
% Specifies a duration value in seconds, minutes, hours, days, or years.
%
% Constructor:
%   obj = aod.schema.primitives.Duration(name, parent, varargin)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Format          aod.schema.validators.Format
    end

    properties (Hidden, SetAccess = protected)
        PRIMITIVE_TYPE = aod.schema.primitives.PrimitiveTypes.DURATION
        OPTIONS = ["Size", "Format", "Default", "Description"];
        VALIDATORS = ["Class", "Format", "Size"];
    end

    methods
        function obj = Duration(name, parent, varargin)
            obj = obj@aod.schema.Primitive(name, parent);

            obj.Format = aod.schema.validators.Format(obj, []);

            % Set default values
            %obj.setClass("duration");
            %obj.setFormat(aod.schema.validators.Format.SECONDS);

            % Complete setup and ensure schema consistency
            obj.parseInputs(varargin{:});
            obj.isInitializing = false;
            obj.checkIntegrity(true);
        end

        function setFormat(obj, value)
            arguments
                obj
                value          string      = ""
            end

            if aod.util.isempty(value)
                obj.Format.setValue([]);
                return
            end

            try
                intervalType = aod.schema.validators.time.IntervalTypes.get(value);
            catch
                error('setFormat:InvalidFormatForDuration',...
                    'Duration format must convert to ms, s, m, h, d or y - was %s', value);
            end

            obj.Format.setValue(intervalType.getFormat());
            obj.checkIntegrity(true);
        end

        function setDefault(obj, value)
            arguments
                obj
                value
            end

            if aod.util.isempty(value)
                obj.Default.setValue([]);
                return
            end

            if obj.Class.isSpecified()
                mustBeA(value, obj.Class.Value)
            end

            obj.Default.setValue(value);
            obj.checkIntegrity(true);
            % TODO: Convert if does not match format?
        end
    end

    methods
        function [tf, ME, excObj] = checkIntegrity(obj, throwErrors)
            arguments
                obj         (1,1)   aod.schema.primitives.Duration
                throwErrors (1,1)   logical = false
            end

            if obj.isInitializing
                tf = true; ME = [];
                return
            end

            [~, ~, excObj] = checkIntegrity@aod.schema.Primitive(obj);

            if obj.Format.isSpecified() && obj.Default.isSpecified() && isduration(obj.Default.Value)
                if ~obj.Format.validate(obj.Default.Value)
                    excObj.addCause(MException( ...
                        "checkIntegrity:InvalidDefaultForamt",...
                        "Format is %s but default format was %s", ...
                        obj.Format.text(), obj.Default.Value.Format));
                end
            end

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