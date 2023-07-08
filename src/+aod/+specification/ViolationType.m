classdef ViolationType 

    enumeration 
        SAME
        CHANGED
        MISSING
        UNEXPECTED
        UNKNOWN
    end

    methods
        function obj = get(input)
            import aod.specification.ViolationType 
            
            if isa(input, 'aod.specification.ViolationType')
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
                    obj = ViolationType.SAME;
                case 'missing'
                    obj = ViolationType.MISSING;
                case 'unexpected'
                    obj = ViolationType.UNEXPECTED;
                case 'changed'
                    obj = ViolationType.CHANGED;
                case 'unknown'
                    obj = ViolationType.UNKNOWN;
                otherwise
                    error('get:InvalidInput',...
                        'Input %s did not match a ViolationType', input);
            end
        end
    end
end