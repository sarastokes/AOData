classdef Duration < aod.schema.primitives.Primitive
% Specifies a duration value in seconds, minutes, hours, days, or years.
%
% Constructor:
%   obj = aod.schema.primitives.Duration(name, parent, varargin)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Units           aod.schema.specs.Units
    end

    properties (Hidden, SetAccess = protected)
        OPTIONS = ["Size", "Units", "Description"];
    end

    methods
        function obj = Duration(name, parent, varargin)
            obj = obj@aod.schema.primitives.Primitive(name, parent);

            obj.Units = aod.schema.specs.Units(obj, []);
            obj.setFormat("duration");
            obj.setUnits("s");

            obj.parseInputs(varargin{:});
        end

        function setUnits(obj, value)
            if isempty(value)
                warning('setUnits:EmptyInput', 'Input is empty. Using default value of "s".');
                obj.setUnits("s");
                return
            end

            value = obj.getUnitsFormat(value);
            obj.setUnits(value);
        end
    end

    methods (Static)
        function out = getUnitsFormat(input)
            switch lower(input)
                case {'s', 'seconds'}
                    out = 's';
                case {'m', 'minutes'}
                    out = 'm';
                case {'h', 'hours'}
                    out = 'h';
                case {'d', 'days'}
                    out = 'd';
                case {'y', 'years'}
                    out = 'y';
                otherwise
                    error('getFormat:InvalidInput',...
                        'Invalid input "%s". Valid inputs are: s, m, h, d, y', input);
            end
            out = string(out);
        end

        function out = getFormatFcn(input)
            out = aod.schema.primitives.Duration.getFormat(input);

            switch out
                case 's'
                    out = @(x) seconds(x);
                case 'm'
                    out = @(x) minutes(x);
                case 'h'
                    out = @(x) hours(x);
                case 'd'
                    out = @(x) days(x);
                case 'y'
                    out = @(x) years(x);
            end
        end
    end
end