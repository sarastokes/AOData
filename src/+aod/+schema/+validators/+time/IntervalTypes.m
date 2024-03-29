classdef IntervalTypes
% INTERVALTYPES
%
% Description:
%   Enumeration of time units

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    enumeration
        YEARS
        DAYS
        HOURS
        MINUTES
        SECONDS
        MILLISECONDS
        UNDEFINED
    end

    methods 
        function out = getFormat(obj)
            import aod.schema.validators.time.IntervalTypes

            switch obj
                case IntervalTypes.SECONDS
                    out = "s";
                case IntervalTypes.MILLISECONDS
                    out = "ms";
                case IntervalTypes.MINUTES
                    out = "m";
                case IntervalTypes.HOURS
                    out = "h";
                case IntervalTypes.DAYS
                    out = "d";
                case IntervalTypes.YEARS
                    out = "y";
                case IntervalTypes.UNDEFINED
                    out = [];
            end
        end
    end

    methods (Static)
        function obj = get(input)
            import aod.schema.validators.time.IntervalTypes

            if isa(input, 'aod.schema.validators.time.IntervalTypes')
                obj = input;
                return
            end

            try
                obj = aod.schema.validators.time.IntervalTypes(upper(input));
                return
            catch
            end

            if ~istext(input)
                error('get:InvalidInput',...
                    'Input must be a IntervalTypes or a string/char of a IntervalTypes, was %s',...
                    class(input));
            end

            switch lower(input)
                case {'s', 'sec', 'second', 'seconds'}
                    obj = IntervalTypes.SECONDS;
                case {'m', 'min', 'minute', 'minutes'}
                    obj = IntervalTypes.MINUTES;
                case {'h', 'hr', 'hour', 'hours'}
                    obj = IntervalTypes.HOURS;
                case {'d', 'day', 'days'}
                    obj = IntervalTypes.DAYS;
                case {'y', 'yr', 'year', 'years'}
                    obj = IntervalTypes.YEARS;
                case {'ms', 'msec', 'millisecond', 'milliseconds'}
                    obj = IntervalTypes.MILLISECONDS;
                otherwise
                    error('get:InvalidIntervalType',...
                        'Invalid input "%s". Valid inputs are: seconds, minutes, hours, days, years or milliseconds', input);
            end
        end

        function out = getFormatFcn(input)
            out = aod.schema.validators.time.IntervalTypes.get(input);
            if out == aod.schema.validators.time.IntervalTypes.UNDEFINED
                out = @(x) x;
            else
                eval(sprintf('out = @(x) %s(x);', input));
            end
        end
    end
end