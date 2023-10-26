classdef TimeUnitTypes
% TIMEUNITTYPES
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

    methods (Static)
        function obj = get(input)
            import aod.schema.primitives.time.TimeUnitTypes

            if isa(input, 'aod.schema.primitives.time.TimeUnitTypes')
                obj = input;
                return
            end

            try
                obj = aod.schema.primitives.time.TimeUnitTypes(upper(input));
                return
            catch
            end

            if ~istext(input)
                error('get:InvalidInput',...
                    'Input must be a TimeUnitTypes or a string/char of a TimeUnitTypes, was %s',...
                    class(input));
            end

            switch lower(input)
                case {'s', 'sec', 'second', 'seconds'}
                    out = TimeUnitTypes.SECONDS;
                case {'m', 'min', 'minute', 'minutes'}
                    out = TimeUnitTypes.MINUTES;
                case {'h', 'hr', 'hour', 'hours'}
                    out = TimeUnitTypes.HOURS;
                case {'d', 'day', 'days'}
                    out = TimeUnitTypes.DAYS;
                case {'y', 'yr', 'year', 'years'}
                    out = TimeUnitTypes.YEARS;
                case {'ms', 'msec', 'millisecond', 'milliseconds'}
                    out = TimeUnitTypes.MILLISECONDS;
                otherwise
                    error('get:InvalidTimeUnitType',...
                        'Invalid input "%s". Valid inputs are: seconds, minutes, hours, days, years or milliseconds', input);
            end


        end

        function out = getFormatFcn(input)
            out = aod.schema.primitives.time.TimeUnitTypes.get(input);
            if out == aod.schema.primitives.time.TimeUnitTypes.UNDEFINED
                out = @(x) x;
            else
                eval(sprintf('out = @(x) %s(x);', input));
            end
        end
    end
end