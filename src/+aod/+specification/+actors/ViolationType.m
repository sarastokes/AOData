classdef ViolationType 

    enumeration 
        SPEC_MISSING
        SPEC_PRESENT
        SPEC_CHANGED
    end

    methods
        function obj = get(input)
            if isa(input, 'aod.specification.actors.ViolationType')
                obj = input;
                return 
            end

            if ~istext(input)
                error('get:InvalidInput',...
                    'Input must be text (char/string) or of class, not %s',...
                    class(input)):
            end

            switch lower(input)
                case {'spec_missing', 'missing'}
                    obj = ViolationType.SPEC_MISSING;
                case {'spec_present', 'present'}
                    obj = ViolationType.SPEC_PRESENT
                case {'spec_changed', 'changed'}
                    obj = ViolationType.SPEC_CHANGED;
                otherwise
                    error('get:InvalidInput',...
                        'Input %s did not match a ViolationType', input);
                end
        end
    end
end