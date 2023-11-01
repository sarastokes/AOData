classdef MatchType
% Enumeration of possible outputs when comparing two schema records
%
% Notes:
%   Actions are describing B, relative to A. For example, REMOVED means that
%   an item is in A but not in B.

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    enumeration
        % When comparing schema B to reference schema A:
        SAME                % Identical in A and B (including both empty)
        CHANGED             % B changed relative to A
        REMOVED             % Missing in B, present in A
        ADDED               % Present in B, missing in A
        UNKNOWN
    end

    methods
        function rgb = getColor(obj)

            actionName = extractAfter(string(obj), "_");

            switch actionName
                case "CHANGED"
                    rgb = hex2rgb('0077ff');
                case "REMOVED"
                    rgb = hex2rgb('ff4040');
                case "ADDED"
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
                case 'removed'
                    obj = MatchType.REMOVED;
                case 'unexpected'
                    obj = MatchType.ADDED;
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