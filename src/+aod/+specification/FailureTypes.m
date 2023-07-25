classdef FailureTypes 

    enumeration
        CLASS 
        SIZE 
        FUNCTION 
    end

    methods
        function obj = get(input)
            
            if isa(input, 'aod.specification.FailureTypes')
                obj = input;
                return 
            end
            
            switch lower(input)
                case 'class'
                    obj = FailureTypes.CLASS;
                case 'size'
                    obj = FailureTypes.SIZE;
                case 'function'
                    obj = FailureTypes.FUNCTION;
                otherwise
                    error('FailureTypes:UnrecognizedType',...
                        'Failure Type %s was not recognized', input);
            end

        end
    end
end