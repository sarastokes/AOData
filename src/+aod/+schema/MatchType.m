classdef MatchType
% Enumeration of possible outputs when comparing two schema entries

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    enumeration
        SAME
        CHANGED
        MISSING
        UNEXPECTED
        UNKNOWN
    end

    methods
        function rgb = getColor(obj)
            switch obj
                case MatchType.CHANGED
                    rgb = hex2rgb('0077ff');
                case MatchType.MISSING
                    rgb = hex2rgb('ff4040');
                case MatchType.UNEXPECTED
                    rgb = hex2rgb('00bd9d');
                otherwise
                    rgb = [1 1 1];
            end
        end
    end

    methods (Static)
        function obj = get(input)
            import aod.schema.MatchType

            if isa(input, 'aod.schema.MatchType')
                obj = input;
                return
            end

            if ~istext(input)
                error('get:InvalidInput',...
                    'Input must be text (char/string) or of class, not %s',...
                    class(input));
            end

            switch lower(input)
                case 'same'
                    obj = MatchType.SAME;
                case 'missing'
                    obj = MatchType.MISSING;
                case 'unexpected'
                    obj = MatchType.UNEXPECTED;
                case 'changed'
                    obj = MatchType.CHANGED;
                case 'unknown'
                    obj = MatchType.UNKNOWN;
                otherwise
                    error('get:InvalidInput',...
                        'Input %s did not match a MatchType', input);
            end
        end
    end
end